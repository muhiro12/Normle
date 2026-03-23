//
//  BaseTransformScreenModel.swift
//  Normle
//
//  Created by Codex on 2026/03/23.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import Foundation
import NormleLibrary
import Observation
import SwiftData
import SwiftUI
import TipKit

@MainActor
@Observable
final class BaseTransformScreenModel {
    var sourceText = String()
    var presetSelectionState = TransformPresetSelectionState()
    var resultText = String()
    var alertMessage: String?
    var qrImage: Image?
    var selectedImageData: Data?
    var importedImageName: String?
    var selectedSourceText = String()
    var pendingSourceForMapping = String()

    var orderedSelectedTransforms: [TransformPreset] {
        presetSelectionState.orderedSelectedPresets
    }

    var transformGroups: [TransformGroup] {
        presetSelectionState.transformGroups
    }

    var isCustomDisabled: Bool {
        presetSelectionState.isCustomDisabled
    }

    var selectedSourceTextValue: String? {
        let trimmed = selectedSourceText.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    var isRunDisabled: Bool {
        if presetSelectionState.selectedPresets.isEmpty {
            return true
        }
        if presetSelectionState.selectedPresets.contains(.qrEncode) {
            return sourceText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        if presetSelectionState.selectedPresets.contains(.qrDecode) {
            return selectedImageData == nil
        }
        return sourceText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func openPresetSelector() {
        NormleTipManager.donate(NormleTipEvents.didOpenPresetSelector)
        TransformPresetTip().invalidate(reason: .actionPerformed)
    }

    func applyPresetSelection(
        _ selection: PresetSelection
    ) {
        presetSelectionState.applyPresetSelection(selection)
    }

    func updateCustomSelection(
        isSelected: Bool,
        preferencesStore: UserPreferencesStore
    ) {
        presetSelectionState.updateCustomSelection(isSelected: isSelected)
        syncPresetSelection(in: preferencesStore)
        resetOutput()
    }

    func updateGroupSelection(
        group: TransformGroup,
        selectedPreset: TransformPreset?,
        preferencesStore: UserPreferencesStore
    ) {
        presetSelectionState.updateGroupSelection(
            group: group,
            selectedPreset: selectedPreset
        )
        syncPresetSelection(in: preferencesStore)
        resetOutput()
    }

    func isGroupDisabled(
        _ group: TransformGroup
    ) -> Bool {
        presetSelectionState.isGroupDisabled(group)
    }

    func prepareMappingCreationFromCurrentSelection() -> Bool {
        guard let selectedSourceTextValue else {
            return false
        }

        return prepareMappingCreation(from: selectedSourceTextValue)
    }

    func prepareMappingCreation(
        from text: String
    ) -> Bool {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else {
            return false
        }

        pendingSourceForMapping = trimmed
        NormleTipManager.donate(NormleTipEvents.didStartMappingFromSelection)
        NormleTipManager.donate(NormleTipEvents.didStartMappingCreation)
        TransformSelectionMappingTip().invalidate(reason: .actionPerformed)
        MappingAddTip().invalidate(reason: .actionPerformed)
        return true
    }

    func executeTransform(
        context: ModelContext,
        mappingRules: [MappingRule],
        preferencesStore: UserPreferencesStore
    ) async {
        do {
            let output = try await NormleMutationWorkflow.runTransform(
                context: context,
                request: .init(
                    sourceText: sourceText,
                    presets: orderedSelectedTransforms,
                    maskRules: activeMaskRules(from: mappingRules),
                    options: preferencesStore.preferences.maskingPreferences.maskingOptions,
                    imageData: selectedImageData
                )
            )
            alertMessage = nil
            resultText = output.outputText
            if let image = output.qrImage {
                qrImage = Image(
                    decorative: image,
                    scale: 1,
                    orientation: .up
                )
            } else {
                qrImage = nil
            }
        } catch {
            handleTransformFailure(error)
        }
    }

    func pasteSourceText() {
        guard let pastedText = ClipboardService.pasteText() else {
            return
        }

        sourceText = pastedText
        selectedSourceText = String()
        resetOutput()
    }

    func clearSourceText() {
        sourceText = String()
        selectedSourceText = String()
        resetOutput()
    }

    func clearSelectedImage() {
        selectedImageData = nil
        importedImageName = nil
        resetOutput()
    }

    func applyImportedImageData(
        _ data: Data,
        suggestedName: String?
    ) {
        selectedImageData = data
        importedImageName = suggestedName
        resetOutput()
    }

    func handleImageImport(
        _ result: Result<URL, Error>
    ) {
        switch result {
        case .success(let url):
            do {
                let data = try Data(contentsOf: url)
                applyImportedImageData(
                    data,
                    suggestedName: url.lastPathComponent
                )
            } catch {
                alertMessage = error.localizedDescription
            }
        case .failure(let error):
            alertMessage = error.localizedDescription
        }
    }

    func dismissAlert() {
        alertMessage = nil
    }
}

private extension BaseTransformScreenModel {
    func syncPresetSelection(
        in preferencesStore: UserPreferencesStore
    ) {
        let selection = presetSelectionState.presetSelection()
        preferencesStore.update { preferences in
            preferences.presetSelection = selection
        }
    }

    func resetOutput() {
        resultText = String()
        qrImage = nil
        alertMessage = nil
    }

    func activeMaskRules(
        from mappingRules: [MappingRule]
    ) -> [MaskingRule] {
        mappingRules
            .filter(\.isEnabled)
            .map(\.maskingRule)
    }

    func handleTransformFailure(
        _ error: any Error
    ) {
        qrImage = nil
        resultText = String()

        if let executionError = error as? TransformExecutionError {
            switch executionError {
            case .pipeline(let pipelineError):
                if pipelineError == .missingImageData {
                    alertMessage = String(localized: "Select an image to decode.")
                } else {
                    alertMessage = pipelineError.localizedDescription
                }
            case .persistence(let persistenceError):
                alertMessage = persistenceError.localizedDescription
            }
            return
        }

        alertMessage = error.localizedDescription
    }
}
