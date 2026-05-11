//
//  PresetSelection.swift
//  Normle
//
//  Created by Hiromu Nakano on 2026/03/03.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

/// Stores the persisted transform preset selection.
public struct PresetSelection: Codable, Equatable, Sendable {
    public var isCustomMappingEnabled: Bool
    public var caseTransform: BaseTransform?
    public var alphanumericWidthTransform: BaseTransform?
    public var spaceWidthTransform: BaseTransform?
    public var katakanaWidthTransform: BaseTransform?
    public var digitsWidthTransform: BaseTransform?
    public var base64Transform: BaseTransform?
    public var urlTransform: BaseTransform?
    public var qrTransform: BaseTransform?

    public init(
        isCustomMappingEnabled: Bool,
        caseTransform: BaseTransform?,
        alphanumericWidthTransform: BaseTransform?,
        spaceWidthTransform: BaseTransform?,
        katakanaWidthTransform: BaseTransform?,
        digitsWidthTransform: BaseTransform?,
        base64Transform: BaseTransform?,
        urlTransform: BaseTransform?,
        qrTransform: BaseTransform?
    ) {
        self.isCustomMappingEnabled = isCustomMappingEnabled
        self.caseTransform = caseTransform
        self.alphanumericWidthTransform = alphanumericWidthTransform
        self.spaceWidthTransform = spaceWidthTransform
        self.katakanaWidthTransform = katakanaWidthTransform
        self.digitsWidthTransform = digitsWidthTransform
        self.base64Transform = base64Transform
        self.urlTransform = urlTransform
        self.qrTransform = qrTransform
    }
}

public extension PresetSelection {
    /// The default preset selection for new users.
    static var defaults: PresetSelection {
        .init(
            isCustomMappingEnabled: false,
            caseTransform: .lowercase,
            alphanumericWidthTransform: nil,
            spaceWidthTransform: nil,
            katakanaWidthTransform: nil,
            digitsWidthTransform: nil,
            base64Transform: nil,
            urlTransform: nil,
            qrTransform: nil
        )
    }
}
