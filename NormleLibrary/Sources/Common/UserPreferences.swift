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
