//
//  PresetSelection.swift
//  Normle
//
//  Created by Hiromu Nakano on 2026/03/03.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

/// Stores the persisted transform preset selection.
public struct PresetSelection: Codable, Equatable, Sendable {
    enum CodingKeys: String, CodingKey {
        case isCustomMappingEnabled
        case caseTransform
        case alphanumericWidthTransform
        case spaceWidthTransform
        case katakanaWidthTransform
        case digitsWidthTransform
        case base64Transform
        case urlTransform
        case qrTransform
    }

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
    /// Decodes a preset selection while ignoring unknown transform raw values.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        isCustomMappingEnabled = try container.decodeIfPresent(Bool.self, forKey: .isCustomMappingEnabled) ?? false
        caseTransform = try container.decodeTransform(forKey: .caseTransform)
        alphanumericWidthTransform = try container.decodeTransform(forKey: .alphanumericWidthTransform)
        spaceWidthTransform = try container.decodeTransform(forKey: .spaceWidthTransform)
        katakanaWidthTransform = try container.decodeTransform(forKey: .katakanaWidthTransform)
        digitsWidthTransform = try container.decodeTransform(forKey: .digitsWidthTransform)
        base64Transform = try container.decodeTransform(forKey: .base64Transform)
        urlTransform = try container.decodeTransform(forKey: .urlTransform)
        qrTransform = try container.decodeTransform(forKey: .qrTransform)
    }

    /// Encodes the current preset selection.
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(isCustomMappingEnabled, forKey: .isCustomMappingEnabled)
        try container.encodeIfPresent(caseTransform, forKey: .caseTransform)
        try container.encodeIfPresent(alphanumericWidthTransform, forKey: .alphanumericWidthTransform)
        try container.encodeIfPresent(spaceWidthTransform, forKey: .spaceWidthTransform)
        try container.encodeIfPresent(katakanaWidthTransform, forKey: .katakanaWidthTransform)
        try container.encodeIfPresent(digitsWidthTransform, forKey: .digitsWidthTransform)
        try container.encodeIfPresent(base64Transform, forKey: .base64Transform)
        try container.encodeIfPresent(urlTransform, forKey: .urlTransform)
        try container.encodeIfPresent(qrTransform, forKey: .qrTransform)
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

private extension KeyedDecodingContainer where Key == PresetSelection.CodingKeys {
    func decodeTransform(
        forKey key: Key
    ) throws -> BaseTransform? {
        guard let rawValue = try decodeIfPresent(String.self, forKey: key) else {
            return nil
        }
        return BaseTransform(rawValue: rawValue)
    }
}
