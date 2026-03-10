//
//  DataAppStorageKey.swift
//  Normle
//
//  Created by Hiromu Nakano on 2026/03/03.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import MHPlatform

public enum DataAppStorageKey: String {
    case userPreferences = "U9r3E7p2"

    public var preferenceKey: MHCodablePreferenceKey<UserPreferences> {
        .init(storageKey: rawValue)
    }
}
