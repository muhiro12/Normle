//
//  MHPreferenceDescriptors+Normle.swift
//  Normle
//
//  Created by Codex on 2026/05/11.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import MHPlatformCore

/// App-owned preference descriptors backed by `UserDefaults`.
public extension MHPreferenceDescriptors {
    /// Subscription state persisted in the standard defaults domain.
    var isSubscribeOn: MHBoolPreferenceDescriptor {
        .init(
            storageKey: NormleUserDefaultsKeys.Standard.isSubscribeOn.rawValue,
            defaultSelection: .standard,
            default: false
        )
    }

    /// iCloud sync preference persisted in the standard defaults domain.
    var isICloudOn: MHBoolPreferenceDescriptor {
        .init(
            storageKey: NormleUserDefaultsKeys.Standard.isICloudOn.rawValue,
            defaultSelection: .standard,
            default: false
        )
    }

    /// URL masking preference persisted in the standard defaults domain.
    var isURLMaskingEnabled: MHBoolPreferenceDescriptor {
        .init(
            storageKey: NormleUserDefaultsKeys.Standard.isURLMaskingEnabled.rawValue,
            defaultSelection: .standard,
            default: false
        )
    }

    /// Email masking preference persisted in the standard defaults domain.
    var isEmailMaskingEnabled: MHBoolPreferenceDescriptor {
        .init(
            storageKey: NormleUserDefaultsKeys.Standard.isEmailMaskingEnabled.rawValue,
            defaultSelection: .standard,
            default: false
        )
    }

    /// Phone masking preference persisted in the standard defaults domain.
    var isPhoneMaskingEnabled: MHBoolPreferenceDescriptor {
        .init(
            storageKey: NormleUserDefaultsKeys.Standard.isPhoneMaskingEnabled.rawValue,
            defaultSelection: .standard,
            default: false
        )
    }

    /// Tip reset marker persisted in the standard defaults domain.
    var shouldResetTipsOnNextLaunch: MHBoolPreferenceDescriptor {
        .init(
            storageKey: NormleUserDefaultsKeys.Standard.shouldResetTipsOnNextLaunch.rawValue,
            defaultSelection: .standard,
            default: false
        )
    }

    /// User preferences payload persisted in the standard defaults domain.
    var userPreferences: MHCodablePreferenceDescriptor<UserPreferences> {
        .init(
            storageKey: NormleUserDefaultsKeys.Standard.userPreferences.rawValue,
            defaultSelection: .standard
        )
    }
}
