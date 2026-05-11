//
//  NormleUserDefaultsKeys.swift
//  Normle
//
//  Created by Codex on 2026/05/11.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

/// Central catalog of app-owned UserDefaults keys.
public enum NormleUserDefaultsKeys {
    public enum Standard: String, CaseIterable {
        case isSubscribeOn = "m5k3I8s9"
        case isICloudOn = "c1o9U2d4"
        case isURLMaskingEnabled = "f3R8q1L0"
        case isEmailMaskingEnabled = "K9m4T2s7"
        case isPhoneMaskingEnabled = "p6V1x8N3"
        case shouldResetTipsOnNextLaunch = "b2N7q4T6"
        case userPreferences = "U9r3E7p2"
    }
}
