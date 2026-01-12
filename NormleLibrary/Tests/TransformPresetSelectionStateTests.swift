@testable import NormleLibrary
import Testing

struct TransformPresetSelectionStateTests {
    @Test func applyPresetSelectionWithQRCodeOverridesOtherSelections() {
        var state = TransformPresetSelectionState()
        let selection = PresetSelection(
            isCustomMappingEnabled: true,
            caseTransform: .lowercase,
            alphanumericWidthTransform: nil,
            spaceWidthTransform: nil,
            katakanaWidthTransform: nil,
            digitsWidthTransform: nil,
            base64Transform: nil,
            urlTransform: nil,
            qrTransform: .qrEncode
        )

        state.applyPresetSelection(selection)

        #expect(state.selectedPresets == [.builtIn(.qrEncode)])
    }

    @Test func updateCustomSelectionClearsQRCode() {
        var state = TransformPresetSelectionState(
            selectedPresets: [.builtIn(.qrEncode)]
        )

        state.updateCustomSelection(isSelected: true)

        #expect(state.selectedPresets.contains(.customMapping))
        #expect(state.selectedPresets.contains(.builtIn(.qrEncode)) == false)
        #expect(state.selectedPresets.contains(.builtIn(.qrDecode)) == false)
    }

    @Test func updateGroupSelectionKeepsOnlyQRCodePreset() {
        var state = TransformPresetSelectionState(
            selectedPresets: [.customMapping, .builtIn(.lowercase)]
        )

        state.updateGroupSelection(
            group: .qrGroup,
            selectedPreset: .builtIn(.qrDecode)
        )

        #expect(state.selectedPresets == [.builtIn(.qrDecode)])
    }

    @Test func presetSelectionReflectsSelectedPresets() {
        let state = TransformPresetSelectionState(
            selectedPresets: [.customMapping, .builtIn(.lowercase), .builtIn(.urlEncode)]
        )

        let selection = state.presetSelection()

        #expect(selection.isCustomMappingEnabled)
        #expect(selection.caseTransform == .lowercase)
        #expect(selection.urlTransform == .urlEncode)
        #expect(selection.qrTransform == nil)
    }

    @Test func isGroupDisabledDependsOnQRCodeSelection() {
        var state = TransformPresetSelectionState()

        #expect(state.isGroupDisabled(.qrGroup) == false)
        #expect(state.isGroupDisabled(.caseGroup) == false)

        state.selectedPresets = [.builtIn(.lowercase)]

        #expect(state.isGroupDisabled(.qrGroup))
        #expect(state.isGroupDisabled(.caseGroup) == false)

        state.selectedPresets = [.builtIn(.qrEncode)]

        #expect(state.isGroupDisabled(.caseGroup))
        #expect(state.isGroupDisabled(.qrGroup) == false)
    }
}
