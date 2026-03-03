//
//  LegacyUserPreferences.swift
//  Normle
//
//  Created by Hiromu Nakano on 2026/03/03.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

struct LegacyUserPreferences: Codable {
    var maskingPreferences: MaskingPreferences
    var presetSelection: PresetSelection

    var userPreferences: UserPreferences {
        .init(
            maskingPreferences: maskingPreferences,
            presetSelection: presetSelection
        )
    }
}
