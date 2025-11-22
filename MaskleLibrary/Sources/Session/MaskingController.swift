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
    public var note = String()
    public var result: MaskingResult?
    public var lastSavedSession: MaskingSession?

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
    public func loadLatestSavedSession(
        context: ModelContext
    ) {
        do {
            var descriptor = FetchDescriptor<MaskingSession>(
                sortBy: [
                    .init(\.createdAt, order: .reverse)
                ]
            )
            descriptor.fetchLimit = 1
            if let session = try context.fetch(descriptor).first {
                lastSavedSession = session
                lastSavedMaskedTextCache = session.maskedText
            }
        } catch {
            assertionFailure(error.localizedDescription)
        }
    }

    @MainActor
    public func anonymize(
        context: ModelContext,
        options: MaskingOptions,
        manualRules: [MaskingRule],
        shouldSaveHistory: Bool,
        isHistoryAutoSaveEnabled: Bool
    ) {
        let generated = MaskingService.anonymize(
            text: sourceText,
            manualRules: manualRules,
            options: options
        )
        result = generated

        guard shouldSaveHistory, isHistoryAutoSaveEnabled else {
            return
        }

        save(
            context: context,
            maskedText: generated.maskedText,
            note: note,
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
        let noteText = note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : note

        autoSaveTask = Task { @MainActor [weak self] in
            guard let self else {
                return
            }

            let delay = autoSaveDelayNanoseconds
            let noteText = noteText

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
                if let session = lastSavedSession {
                    update(
                        context: context,
                        session: session,
                        maskedText: maskedText,
                        note: noteText,
                        mappings: mappings
                    )
                } else {
                    save(
                        context: context,
                        maskedText: maskedText,
                        note: noteText,
                        mappings: mappings
                    )
                }
                return
            }

            save(
                context: context,
                maskedText: maskedText,
                note: noteText,
                mappings: mappings
            )
        }
    }
}

private extension MaskingController {
    func save(
        context: ModelContext,
        maskedText: String,
        note: String?,
        mappings: [Mapping]
    ) {
        do {
            lastSavedSession = try SessionService.saveSession(
                context: context,
                maskedText: maskedText,
                note: note?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == true ? nil : note,
                mappings: mappings
            )
            lastSavedMaskedTextCache = maskedText
        } catch {
            assertionFailure(error.localizedDescription)
        }
    }

    func update(
        context: ModelContext,
        session: MaskingSession,
        maskedText: String,
        note: String?,
        mappings: [Mapping]
    ) {
        do {
            lastSavedSession = try SessionService.updateSession(
                context: context,
                session: session,
                maskedText: maskedText,
                note: note,
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
