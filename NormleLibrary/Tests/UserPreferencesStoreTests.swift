//
//  UserPreferencesStoreTests.swift
//  Normle
//
//  Created by Codex on 2026/03/10.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import Foundation
@testable import NormleLibrary
import Testing

struct UserPreferencesStoreTests {
    @MainActor
    @Test
    func initLoadsPersistedCurrentPayload() throws {
        let userDefaults = makeUserDefaults()
        let expectedPreferences = UserPreferences(
            maskingPreferences: .init(
                isURLMaskingEnabled: false,
                isEmailMaskingEnabled: true,
                isPhoneMaskingEnabled: false
            ),
            presetSelection: .init(
                isCustomMappingEnabled: true,
                caseTransform: .uppercase,
                alphanumericWidthTransform: .halfwidthAlphanumericToFullwidth,
                spaceWidthTransform: nil,
                katakanaWidthTransform: nil,
                digitsWidthTransform: nil,
                base64Transform: nil,
                urlTransform: nil,
                qrTransform: nil
            )
        )
        let data = try JSONEncoder().encode(expectedPreferences)

        userDefaults.set(
            data,
            forKey: NormleUserDefaultsKeys.Standard.userPreferences.rawValue
        )

        let store = UserPreferencesStore(userDefaults: userDefaults)

        #expect(store.preferences == expectedPreferences)
        let storedData = try #require(
            userDefaults.data(
                forKey: NormleUserDefaultsKeys.Standard.userPreferences.rawValue
            )
        )

        #expect(storedData == data)
    }

    @MainActor
    @Test
    func updatePersistsMutatedPreferences() throws {
        let userDefaults = makeUserDefaults()
        let store = UserPreferencesStore(userDefaults: userDefaults)

        store.update { preferences in
            preferences.maskingPreferences.isPhoneMaskingEnabled = false
            preferences.presetSelection.base64Transform = .base64Encode
        }

        let storedData = try #require(
            userDefaults.data(
                forKey: NormleUserDefaultsKeys.Standard.userPreferences.rawValue
            )
        )
        let decoded = try JSONDecoder().decode(UserPreferences.self, from: storedData)

        #expect(decoded.maskingPreferences.isPhoneMaskingEnabled == false)
        #expect(decoded.presetSelection.base64Transform == .base64Encode)
    }
}

private extension UserPreferencesStoreTests {
    func makeUserDefaults() -> UserDefaults {
        let suiteName = "NormleLibraryTests.UserPreferencesStore.\(UUID().uuidString)"
        let userDefaults = UserDefaults(suiteName: suiteName) ?? .standard
        userDefaults.removePersistentDomain(forName: suiteName)
        return userDefaults
    }
}
