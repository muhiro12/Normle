//
//  TransformPresetSelectionState.swift
//
//
//  Created by Hiromu Nakano on 2025/11/23.
//

import Foundation

public struct TransformPresetSelectionState: Equatable {
    public var selectedPresets: Set<TransformPreset> = []

    public init(
        selectedPresets: Set<TransformPreset> = []
    ) {
        self.selectedPresets = selectedPresets
    }

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
        for option in group.options {
            if selectedPresets.contains(option) {
                return option
            }
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

public enum TransformPreset: Hashable, Identifiable, Sendable {
    case builtIn(BaseTransform)
    case customMapping

    public static var qrEncode: Self {
        .builtIn(.qrEncode)
    }

    public static var qrDecode: Self {
        .builtIn(.qrDecode)
    }

    public var id: String {
        switch self {
        case .builtIn(let transform):
            return "builtIn_\(transform.id)"
        case .customMapping:
            return "customMapping"
        }
    }

    public var title: String {
        switch self {
        case .builtIn(let transform):
            return transform.title
        case .customMapping:
            return String(localized: "Custom")
        }
    }

    public var isQRCodeOnly: Bool {
        switch self {
        case .builtIn(let transform):
            return transform == .qrEncode || transform == .qrDecode
        case .customMapping:
            return false
        }
    }

    public static var allCases: [Self] {
        let builtIns: [Self] = BaseTransform.allCases.map { transform in
            .builtIn(transform) as Self
        }
        return [
            .customMapping
        ] + builtIns
    }
}

public struct TransformGroup: Identifiable, Equatable, Sendable {
    public let id: String
    public let title: String
    public let options: [TransformPreset]
    public let isQRCodeGroup: Bool

    public init(
        title: String,
        options: [TransformPreset],
        isQRCodeGroup: Bool
    ) {
        self.id = title
        self.title = title
        self.options = options
        self.isQRCodeGroup = isQRCodeGroup
    }
}

public extension TransformGroup {
    static let caseGroup: TransformGroup = .init(
        title: String(localized: "Case"),
        options: [
            .builtIn(.lowercase),
            .builtIn(.uppercase)
        ],
        isQRCodeGroup: false
    )

    static let alphanumericWidthGroup: TransformGroup = .init(
        title: String(localized: "Alphanumeric Width"),
        options: [
            .builtIn(.fullwidthAlphanumericToHalfwidth),
            .builtIn(.halfwidthAlphanumericToFullwidth)
        ],
        isQRCodeGroup: false
    )

    static let spaceWidthGroup: TransformGroup = .init(
        title: String(localized: "Space Width"),
        options: [
            .builtIn(.fullwidthSpaceToHalfwidth),
            .builtIn(.halfwidthSpaceToFullwidth)
        ],
        isQRCodeGroup: false
    )

    static let katakanaWidthGroup: TransformGroup = .init(
        title: String(localized: "Katakana Width"),
        options: [
            .builtIn(.halfwidthKatakanaToFullwidth),
            .builtIn(.fullwidthKatakanaToHalfwidth)
        ],
        isQRCodeGroup: false
    )

    static let digitsWidthGroup: TransformGroup = .init(
        title: String(localized: "Digits Width"),
        options: [
            .builtIn(.fullwidthDigitsToHalfwidth),
            .builtIn(.halfwidthDigitsToFullwidth)
        ],
        isQRCodeGroup: false
    )

    static let base64Group: TransformGroup = .init(
        title: String(localized: "Base64"),
        options: [
            .builtIn(.base64Encode),
            .builtIn(.base64Decode)
        ],
        isQRCodeGroup: false
    )

    static let urlGroup: TransformGroup = .init(
        title: String(localized: "URL"),
        options: [
            .builtIn(.urlEncode),
            .builtIn(.urlDecode)
        ],
        isQRCodeGroup: false
    )

    static let qrGroup: TransformGroup = .init(
        title: String(localized: "QR"),
        options: [
            .builtIn(.qrEncode),
            .builtIn(.qrDecode)
        ],
        isQRCodeGroup: true
    )

    static let allGroups: [TransformGroup] = [
        caseGroup,
        alphanumericWidthGroup,
        spaceWidthGroup,
        katakanaWidthGroup,
        digitsWidthGroup,
        base64Group,
        urlGroup,
        qrGroup
    ]
}
