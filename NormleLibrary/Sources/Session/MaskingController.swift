//
//  MaskingController.swift
//
//
//  Created by Hiromu Nakano on 2025/11/23.
//

import Foundation
import Observation
import SwiftData

@Observable
public final class MaskingController {
    private let autoSaveDelayNanoseconds: UInt64
    private let autoSaveSimilarityThreshold: Double

    private var autoSaveTask: Task<Void, Never>?

    private var lastSavedTargetTextCache: String?

    public var sourceText = String()
    public var result: MaskingResult?
    public var lastSavedRecord: TransformRecord?

    public init(
        autoSaveDelayNanoseconds: UInt64 = 2_000_000_000,
        autoSaveSimilarityThreshold: Double = 0.9
    ) {
        self.autoSaveDelayNanoseconds = autoSaveDelayNanoseconds
        self.autoSaveSimilarityThreshold = autoSaveSimilarityThreshold
    }

    deinit {
        autoSaveTask?.cancel()
    }

    @MainActor
    public func loadLatestSavedRecord(
        context: ModelContext
    ) {
        do {
            var descriptor = FetchDescriptor<TransformRecord>(
                sortBy: [
                    .init(\.date, order: .reverse)
                ]
            )
            descriptor.fetchLimit = 1
            if let record = try context.fetch(descriptor).first {
                lastSavedRecord = record
                lastSavedTargetTextCache = record.targetText
            }
        } catch {
            assertionFailure(error.localizedDescription)
        }
    }

    @MainActor
    public func anonymize(
        context: ModelContext,
        options: MaskingOptions,
        maskRules: [MaskingRule],
        shouldSaveHistory: Bool,
        isHistoryAutoSaveEnabled: Bool
    ) {
        let generated = MaskingService.anonymize(
            text: sourceText,
            maskRules: maskRules,
            options: options
        )
        result = generated

        guard shouldSaveHistory, isHistoryAutoSaveEnabled else {
            return
        }

        save(
            context: context,
            sourceText: "",
            targetText: generated.maskedText,
            mappings: generated.mappings
        )
    }

    @MainActor
    public func scheduleAutoSave(
        context: ModelContext,
        isHistoryAutoSaveEnabled: Bool
    ) {
        guard isHistoryAutoSaveEnabled else {
            return
        }

        guard let currentResult = result else {
            return
        }

        autoSaveTask?.cancel()

        let targetText = currentResult.maskedText
        let mappings = currentResult.mappings
        let sourceTextToStore = ""

        autoSaveTask = Task { @MainActor [weak self] in
            guard let self else {
                return
            }

            let delay = autoSaveDelayNanoseconds

            do {
                try await Task.sleep(nanoseconds: delay)
            } catch {
                return
            }

            guard Task.isCancelled == false else {
                return
            }

            guard let latestResult = result, latestResult.maskedText == targetText else {
                return
            }

            if isSimilarToLastSaved(targetText: targetText) {
                if let record = lastSavedRecord {
                    update(
                        context: context,
                        record: record,
                        sourceText: sourceTextToStore,
                        targetText: targetText,
                        mappings: mappings
                    )
                } else {
                    save(
                        context: context,
                        sourceText: sourceTextToStore,
                        targetText: targetText,
                        mappings: mappings
                    )
                }
                return
            }

            save(
                context: context,
                sourceText: sourceTextToStore,
                targetText: targetText,
                mappings: mappings
            )
        }
    }
}

private extension MaskingController {
    func save(
        context: ModelContext,
        sourceText: String,
        targetText: String,
        mappings: [Mapping]
    ) {
        do {
            lastSavedRecord = try TransformRecordService.saveRecord(
                context: context,
                sourceText: sourceText,
                targetText: targetText,
                mappings: mappings
            )
            lastSavedTargetTextCache = targetText
        } catch {
            assertionFailure(error.localizedDescription)
        }
    }

    func update(
        context: ModelContext,
        record: TransformRecord,
        sourceText: String,
        targetText: String,
        mappings: [Mapping]
    ) {
        do {
            lastSavedRecord = try TransformRecordService.updateRecord(
                context: context,
                record: record,
                sourceText: sourceText,
                targetText: targetText,
                mappings: mappings
            )
            lastSavedTargetTextCache = targetText
        } catch {
            assertionFailure(error.localizedDescription)
        }
    }

    func isSimilarToLastSaved(
        targetText: String
    ) -> Bool {
        guard let lastSaved = lastSavedTargetTextCache else {
            return false
        }

        let similarity = MaskingSimilarity.similarityScore(
            between: lastSaved,
            and: targetText
        )

        return similarity >= autoSaveSimilarityThreshold
    }
}
