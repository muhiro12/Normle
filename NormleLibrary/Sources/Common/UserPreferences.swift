//
//  UserPreferences.swift
//
//
//  Created by Hiromu Nakano on 2025/11/23.
//

import Foundation

public struct UserPreferences: Codable, Equatable {
    public static let currentVersion = 1

    public var version: Int
    public var maskingPreferences: MaskingPreferences
    public var presetSelection: PresetSelection

    enum CodingKeys: String, CodingKey {
        case version
        case maskingPreferences
        case presetSelection
    }

    public init(
        version: Int = Self.currentVersion,
        maskingPreferences: MaskingPreferences,
        presetSelection: PresetSelection
    ) {
        self.version = version
        self.maskingPreferences = maskingPreferences
        self.presetSelection = presetSelection
    }
}

public extension UserPreferences {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        version = try container.decodeIfPresent(Int.self, forKey: .version) ?? Self.currentVersion
        maskingPreferences = try container.decodeIfPresent(
            MaskingPreferences.self,
            forKey: .maskingPreferences
        ) ?? .defaults
        presetSelection = try container.decodeIfPresent(
            PresetSelection.self,
            forKey: .presetSelection
        ) ?? .defaults
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(version, forKey: .version)
        try container.encode(maskingPreferences, forKey: .maskingPreferences)
        try container.encode(presetSelection, forKey: .presetSelection)
    }
}

public extension UserPreferences {
    static var defaults: UserPreferences {
        .init(
            maskingPreferences: .defaults,
            presetSelection: .defaults
        )
    }

    static func decode(from data: Data) -> UserPreferences {
        guard data.isEmpty == false else {
            return .defaults
        }

        let decoder = JSONDecoder()
        if let decoded = try? decoder.decode(UserPreferences.self, from: data) {
            return decoded.normalized()
        }

        if let decoded = try? decoder.decode(LegacyUserPreferences.self, from: data) {
            return decoded.userPreferences
        }

        return .defaults
    }

    func encode() -> Data {
        (try? JSONEncoder().encode(self)) ?? Data()
    }

    private func normalized() -> UserPreferences {
        guard version != Self.currentVersion else {
            return self
        }

        return .init(
            version: Self.currentVersion,
            maskingPreferences: maskingPreferences,
            presetSelection: presetSelection
        )
    }
}

private struct LegacyUserPreferences: Codable {
    var maskingPreferences: MaskingPreferences
    var presetSelection: PresetSelection

    var userPreferences: UserPreferences {
        .init(
            maskingPreferences: maskingPreferences,
            presetSelection: presetSelection
        )
    }
}

public struct MaskingPreferences: Codable, Equatable {
    public var isURLMaskingEnabled: Bool
    public var isEmailMaskingEnabled: Bool
    public var isPhoneMaskingEnabled: Bool

    enum CodingKeys: String, CodingKey {
        case isURLMaskingEnabled
        case isEmailMaskingEnabled
        case isPhoneMaskingEnabled
    }

    public init(
        isURLMaskingEnabled: Bool,
        isEmailMaskingEnabled: Bool,
        isPhoneMaskingEnabled: Bool
    ) {
        self.isURLMaskingEnabled = isURLMaskingEnabled
        self.isEmailMaskingEnabled = isEmailMaskingEnabled
        self.isPhoneMaskingEnabled = isPhoneMaskingEnabled
    }
}

public extension MaskingPreferences {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        isURLMaskingEnabled = try container.decodeIfPresent(Bool.self, forKey: .isURLMaskingEnabled) ?? true
        isEmailMaskingEnabled = try container.decodeIfPresent(Bool.self, forKey: .isEmailMaskingEnabled) ?? true
        isPhoneMaskingEnabled = try container.decodeIfPresent(Bool.self, forKey: .isPhoneMaskingEnabled) ?? true
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(isURLMaskingEnabled, forKey: .isURLMaskingEnabled)
        try container.encode(isEmailMaskingEnabled, forKey: .isEmailMaskingEnabled)
        try container.encode(isPhoneMaskingEnabled, forKey: .isPhoneMaskingEnabled)
    }
}

public extension MaskingPreferences {
    static var defaults: MaskingPreferences {
        .init(
            isURLMaskingEnabled: true,
            isEmailMaskingEnabled: true,
            isPhoneMaskingEnabled: true
        )
    }

    var maskingOptions: MaskingOptions {
        .init(
            isURLMaskingEnabled: isURLMaskingEnabled,
            isEmailMaskingEnabled: isEmailMaskingEnabled,
            isPhoneMaskingEnabled: isPhoneMaskingEnabled
        )
    }
}

public struct PresetSelection: Codable, Equatable {
    public var isCustomMappingEnabled: Bool
    public var caseTransform: BaseTransform?
    public var alphanumericWidthTransform: BaseTransform?
    public var spaceWidthTransform: BaseTransform?
    public var katakanaWidthTransform: BaseTransform?
    public var digitsWidthTransform: BaseTransform?
    public var base64Transform: BaseTransform?
    public var urlTransform: BaseTransform?
    public var qrTransform: BaseTransform?

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
