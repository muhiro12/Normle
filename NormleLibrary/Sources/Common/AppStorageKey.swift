//
//  AppStorageKey.swift
//
//
//  Created by Hiromu Nakano on 2025/11/23.
//

import SwiftUI

public enum BoolAppStorageKey: String {
    case isSubscribeOn = "m5k3I8s9"
    case isICloudOn = "c1o9U2d4"
    case isURLMaskingEnabled = "f3R8q1L0"
    case isEmailMaskingEnabled = "K9m4T2s7"
    case isPhoneMaskingEnabled = "p6V1x8N3"
    case isHistoryAutoSaveEnabled = "J5c0W7y2"
}

public extension AppStorage {
    init(_ key: BoolAppStorageKey) where Value == Bool {
        self.init(wrappedValue: false, key.rawValue)
    }

    init(
        wrappedValue: Value,
        _ key: BoolAppStorageKey
    ) where Value == Bool {
        self.init(
            wrappedValue: wrappedValue,
            key.rawValue
        )
    }
}
