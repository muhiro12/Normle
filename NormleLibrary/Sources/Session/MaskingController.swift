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

    private var lastSavedMaskedTextCache: String?

    public var sourceText = String()
    public var result: MaskingResult?
    public var lastSavedRecord: MaskRecord?

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
            var descriptor = FetchDescriptor<MaskRecord>(
                sortBy: [
                    .init(\.date, order: .reverse)
                ]
            )
            descriptor.fetchLimit = 1
            if let record = try context.fetch(descriptor).first {
                lastSavedRecord = record
                lastSavedMaskedTextCache = record.maskedText
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
            maskedText: generated.maskedText,
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

        let maskedText = currentResult.maskedText
        let mappings = currentResult.mappings

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

            guard let latestResult = result, latestResult.maskedText == maskedText else {
                return
            }

            if isSimilarToLastSaved(maskedText: maskedText) {
                if let record = lastSavedRecord {
                    update(
                        context: context,
                        record: record,
                        maskedText: maskedText,
                        mappings: mappings
                    )
                } else {
                    save(
                        context: context,
                        maskedText: maskedText,
                        mappings: mappings
                    )
                }
                return
            }

            save(
                context: context,
                maskedText: maskedText,
                mappings: mappings
            )
        }
    }
}

private extension MaskingController {
    func save(
        context: ModelContext,
        maskedText: String,
        mappings: [Mapping]
    ) {
        do {
            lastSavedRecord = try MaskRecordService.saveRecord(
                context: context,
                maskedText: maskedText,
                mappings: mappings
            )
            lastSavedMaskedTextCache = maskedText
        } catch {
            assertionFailure(error.localizedDescription)
        }
    }

    func update(
        context: ModelContext,
        record: MaskRecord,
        maskedText: String,
        mappings: [Mapping]
    ) {
        do {
            lastSavedRecord = try MaskRecordService.updateRecord(
                context: context,
                record: record,
                maskedText: maskedText,
                mappings: mappings
            )
            lastSavedMaskedTextCache = maskedText
        } catch {
            assertionFailure(error.localizedDescription)
        }
    }

    func isSimilarToLastSaved(
        maskedText: String
    ) -> Bool {
        guard let lastSaved = lastSavedMaskedTextCache else {
            return false
        }

        let similarity = MaskingSimilarity.similarityScore(
            between: lastSaved,
            and: maskedText
        )

        return similarity >= autoSaveSimilarityThreshold
    }
}
