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
    /// The default user preferences for a new installation.
    static var defaults: UserPreferences {
        .init(
            maskingPreferences: .defaults,
            presetSelection: .defaults
        )
    }
}
