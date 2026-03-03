//
//  AppStorageExtension.swift
//  Normle
//
//  Created by Hiromu Nakano on 2025/11/23.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import SwiftUI

public extension AppStorage {
    /// Creates a Boolean app storage value for the given key.
    init(_ key: BoolAppStorageKey) where Value == Bool {
        self.init(wrappedValue: false, key.rawValue)
    }

    /// Creates a Boolean app storage value with the provided default value.
    init(
        wrappedValue: Value,
        _ key: BoolAppStorageKey
    ) where Value == Bool {
        self.init(
            wrappedValue: wrappedValue,
            key.rawValue
        )
    }

    /// Creates a data app storage value for the given key.
    init(_ key: DataAppStorageKey) where Value == Data {
        self.init(wrappedValue: Data(), key.rawValue)
    }

    /// Creates a data app storage value with the provided default value.
    init(
        wrappedValue: Value,
        _ key: DataAppStorageKey
    ) where Value == Data {
        self.init(
            wrappedValue: wrappedValue,
            key.rawValue
        )
    }
}
