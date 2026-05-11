//
//  PreferenceDescriptorTests.swift
//  Normle
//
//  Created by Codex on 2026/05/11.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import MHPlatformCore
@testable import NormleLibrary
import Testing

@Suite("Preference descriptors")
struct PreferenceDescriptorTests {
    @Test
    func boolDescriptorsUseCatalogKeys() {
        let descriptors = MHPreferenceDescriptors()

        #expect(
            descriptors.isSubscribeOn.storageKey
                == NormleUserDefaultsKeys.Standard.isSubscribeOn.rawValue
        )
        #expect(
            descriptors.isICloudOn.storageKey
                == NormleUserDefaultsKeys.Standard.isICloudOn.rawValue
        )
        #expect(
            descriptors.isURLMaskingEnabled.storageKey
                == NormleUserDefaultsKeys.Standard.isURLMaskingEnabled.rawValue
        )
        #expect(
            descriptors.isEmailMaskingEnabled.storageKey
                == NormleUserDefaultsKeys.Standard.isEmailMaskingEnabled.rawValue
        )
        #expect(
            descriptors.isPhoneMaskingEnabled.storageKey
                == NormleUserDefaultsKeys.Standard.isPhoneMaskingEnabled.rawValue
        )
        #expect(
            descriptors.shouldResetTipsOnNextLaunch.storageKey
                == NormleUserDefaultsKeys.Standard.shouldResetTipsOnNextLaunch.rawValue
        )
    }

    @Test
    func userPreferencesDescriptorUsesCatalogKey() {
        #expect(
            MHPreferenceDescriptors().userPreferences.storageKey
                == NormleUserDefaultsKeys.Standard.userPreferences.rawValue
        )
    }
}
