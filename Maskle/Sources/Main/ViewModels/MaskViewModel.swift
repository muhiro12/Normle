//
//  MaskViewModel.swift
//
//
//  Created by Hiromu Nakano on 2025/11/23.
//

import Foundation
import MaskleLibrary
import Observation
import SwiftData

@Observable
final class MaskViewModel {
    var sourceText = String()
    var note = String()
    var result: MaskingResult?
    var lastSavedSession: MaskingSession?

    func anonymize(
        context: ModelContext,
        settingsStore: SettingsStore,
        manualRules: [MaskingRule],
        shouldSaveHistory: Bool
    ) {
        let options = MaskingOptions(
            isURLMaskingEnabled: settingsStore.isURLMaskingEnabled,
            isEmailMaskingEnabled: settingsStore.isEmailMaskingEnabled,
            isPhoneMaskingEnabled: settingsStore.isPhoneMaskingEnabled
        )
        let generated = MaskingService.anonymize(
            text: sourceText,
            manualRules: manualRules,
            options: options
        )
        result = generated

        guard shouldSaveHistory, settingsStore.isHistoryAutoSaveEnabled else {
            return
        }

        do {
            lastSavedSession = try SessionService.saveSession(
                context: context,
                maskedText: generated.maskedText,
                note: note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : note,
                mappings: generated.mappings,
                historyLimit: settingsStore.historyLimit
            )
        } catch {
            assertionFailure(error.localizedDescription)
        }
    }
}
