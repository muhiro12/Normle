//
//  BoolAppStorageKey.swift
//  Normle
//
//  Created by Hiromu Nakano on 2026/03/03.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import MHPlatformCore

public enum BoolAppStorageKey: String, MHBoolPreferenceKeyRepresentable {
    case isSubscribeOn = "m5k3I8s9"
    case isICloudOn = "c1o9U2d4"
    case isURLMaskingEnabled = "f3R8q1L0"
    case isEmailMaskingEnabled = "K9m4T2s7"
    case isPhoneMaskingEnabled = "p6V1x8N3"
    case shouldResetTipsOnNextLaunch = "b2N7q4T6"

    public var preferenceKey: MHBoolPreferenceKey {
        .init(storageKey: rawValue)
    }
}
