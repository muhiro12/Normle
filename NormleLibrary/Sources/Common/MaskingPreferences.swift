//
//  MaskingPreferences.swift
//  Normle
//
//  Created by Hiromu Nakano on 2026/03/03.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

/// Stores the persisted automatic masking preferences.
public struct MaskingPreferences: Codable, Equatable {
    enum CodingKeys: String, CodingKey {
        case isURLMaskingEnabled
        case isEmailMaskingEnabled
        case isPhoneMaskingEnabled
    }

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
    /// Decodes masking preferences while keeping defaults for missing fields.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        isURLMaskingEnabled = try container.decodeIfPresent(Bool.self, forKey: .isURLMaskingEnabled) ?? true
        isEmailMaskingEnabled = try container.decodeIfPresent(Bool.self, forKey: .isEmailMaskingEnabled) ?? true
        isPhoneMaskingEnabled = try container.decodeIfPresent(Bool.self, forKey: .isPhoneMaskingEnabled) ?? true
    }

    /// Encodes masking preferences using the current storage schema.
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(isURLMaskingEnabled, forKey: .isURLMaskingEnabled)
        try container.encode(isEmailMaskingEnabled, forKey: .isEmailMaskingEnabled)
        try container.encode(isPhoneMaskingEnabled, forKey: .isPhoneMaskingEnabled)
    }
}

public extension MaskingPreferences {
    /// The default masking preferences for new users.
    static var defaults: MaskingPreferences {
        .init(
            isURLMaskingEnabled: true,
            isEmailMaskingEnabled: true,
            isPhoneMaskingEnabled: true
        )
    }

    /// Converts the persisted preferences into runtime masking options.
    var maskingOptions: MaskingOptions {
        .init(
            isURLMaskingEnabled: isURLMaskingEnabled,
            isEmailMaskingEnabled: isEmailMaskingEnabled,
            isPhoneMaskingEnabled: isPhoneMaskingEnabled
        )
    }
}
