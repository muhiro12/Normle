//
//  TransformPresetSelectionState.swift
//  Normle
//
//  Created by Hiromu Nakano on 2025/11/23.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import Foundation

public struct TransformPresetSelectionState: Equatable {
    public var selectedPresets: Set<TransformPreset> = []

    public var transformGroups: [TransformGroup] {
        TransformGroup.allGroups
    }

    public var orderedSelectedPresets: [TransformPreset] {
        var orderedPresets: [TransformPreset] = []
        if selectedPresets.contains(.customMapping) {
            orderedPresets.append(.customMapping)
        }
        for transform in BaseTransform.allCases {
            let preset = TransformPreset.builtIn(transform)
            if selectedPresets.contains(preset) {
                orderedPresets.append(preset)
            }
        }
        return orderedPresets
    }

    public var isQRSelected: Bool {
        selectedPresets.contains(.qrEncode) || selectedPresets.contains(.qrDecode)
    }

    public var isCustomDisabled: Bool {
        isQRSelected
    }

    public init(
        selectedPresets: Set<TransformPreset> = []
    ) {
        self.selectedPresets = selectedPresets
    }

    public func isGroupDisabled(_ group: TransformGroup) -> Bool {
        if group.isQRCodeGroup {
            return selectedPresets.isEmpty == false && isQRSelected == false
        }
        return isQRSelected
    }

    public mutating func applyPresetSelection(_ selection: PresetSelection) {
        if let qrTransform = selection.qrTransform,
           let qrPreset = presetForGroupSelection(
            qrTransform,
            group: .qrGroup
           ) {
            selectedPresets = [qrPreset]
            return
        }

        var updatedSelection: Set<TransformPreset> = []
        if selection.isCustomMappingEnabled {
            updatedSelection.insert(.customMapping)
        }
        if let preset = presetForGroupSelection(selection.caseTransform, group: .caseGroup) {
            updatedSelection.insert(preset)
        }
        if let preset = presetForGroupSelection(selection.alphanumericWidthTransform, group: .alphanumericWidthGroup) {
            updatedSelection.insert(preset)
        }
        if let preset = presetForGroupSelection(selection.spaceWidthTransform, group: .spaceWidthGroup) {
            updatedSelection.insert(preset)
        }
        if let preset = presetForGroupSelection(selection.katakanaWidthTransform, group: .katakanaWidthGroup) {
            updatedSelection.insert(preset)
        }
        if let preset = presetForGroupSelection(selection.digitsWidthTransform, group: .digitsWidthGroup) {
            updatedSelection.insert(preset)
        }
        if let preset = presetForGroupSelection(selection.base64Transform, group: .base64Group) {
            updatedSelection.insert(preset)
        }
        if let preset = presetForGroupSelection(selection.urlTransform, group: .urlGroup) {
            updatedSelection.insert(preset)
        }
        selectedPresets = updatedSelection
    }

    public mutating func updateCustomSelection(isSelected: Bool) {
        if isSelected {
            selectedPresets.remove(.qrEncode)
            selectedPresets.remove(.qrDecode)
            selectedPresets.insert(.customMapping)
        } else {
            selectedPresets.remove(.customMapping)
        }
    }

    public mutating func updateGroupSelection(
        group: TransformGroup,
        selectedPreset: TransformPreset?
    ) {
        for option in group.options {
            selectedPresets.remove(option)
        }
        guard let selectedPreset else {
            return
        }
        if group.isQRCodeGroup {
            selectedPresets = [selectedPreset]
        } else {
            selectedPresets.remove(.qrEncode)
            selectedPresets.remove(.qrDecode)
            selectedPresets.insert(selectedPreset)
        }
    }

    public func presetSelection() -> PresetSelection {
        .init(
            isCustomMappingEnabled: selectedPresets.contains(.customMapping),
            caseTransform: selectedTransform(in: .caseGroup),
            alphanumericWidthTransform: selectedTransform(in: .alphanumericWidthGroup),
            spaceWidthTransform: selectedTransform(in: .spaceWidthGroup),
            katakanaWidthTransform: selectedTransform(in: .katakanaWidthGroup),
            digitsWidthTransform: selectedTransform(in: .digitsWidthGroup),
            base64Transform: selectedTransform(in: .base64Group),
            urlTransform: selectedTransform(in: .urlGroup),
            qrTransform: selectedTransform(in: .qrGroup)
        )
    }

    public func selectedPreset(in group: TransformGroup) -> TransformPreset? {
        for option in group.options where selectedPresets.contains(option) {
            return option
        }
        return nil
    }

    public func presetForGroupSelection(
        _ transform: BaseTransform?,
        group: TransformGroup
    ) -> TransformPreset? {
        guard let transform else {
            return nil
        }
        let preset = TransformPreset.builtIn(transform)
        guard group.options.contains(preset) else {
            return nil
        }
        return preset
    }

    public func selectedTransform(in group: TransformGroup) -> BaseTransform? {
        for option in group.options {
            if selectedPresets.contains(option),
               case .builtIn(let transform) = option {
                return transform
            }
        }
        return nil
    }
}
