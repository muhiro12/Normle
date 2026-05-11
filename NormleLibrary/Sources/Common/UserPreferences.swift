//
//  UserPreferences.swift
//  Normle
//
//  Created by Hiromu Nakano on 2025/11/23.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import Foundation

/// Stores the persisted user preferences for masking and transform presets.
public struct UserPreferences: Codable, Equatable, Sendable {
    enum CodingKeys: String, CodingKey {
        case maskingPreferences
        case presetSelection
    }

    public var maskingPreferences: MaskingPreferences
    public var presetSelection: PresetSelection

    public init(
        maskingPreferences: MaskingPreferences,
        presetSelection: PresetSelection
    ) {
        self.maskingPreferences = maskingPreferences
        self.presetSelection = presetSelection
    }
}

public extension UserPreferences {
    /// Decodes user preferences while falling back to defaults for missing fields.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        maskingPreferences = try container.decodeIfPresent(
            MaskingPreferences.self,
            forKey: .maskingPreferences
        ) ?? .defaults
        presetSelection = try container.decodeIfPresent(
            PresetSelection.self,
            forKey: .presetSelection
        ) ?? .defaults
    }

    /// Encodes user preferences using the current storage schema.
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(maskingPreferences, forKey: .maskingPreferences)
        try container.encode(presetSelection, forKey: .presetSelection)
    }
}

public extension UserPreferences {
    /// The default user preferences for a new installation.
    static var defaults: UserPreferences {
        .init(
            maskingPreferences: .defaults,
            presetSelection: .defaults
        )
    }

    /// Decodes user preferences from persisted data.
    static func decode(from data: Data) -> UserPreferences {
        guard data.isEmpty == false else {
            return .defaults
        }

        let decoder = JSONDecoder()
        if let decoded = try? decoder.decode(UserPreferences.self, from: data) {
            return decoded
        }

        return .defaults
    }

    /// Encodes user preferences into persisted data.
    func encode() -> Data {
        (try? JSONEncoder().encode(self)) ?? Data()
    }
}
