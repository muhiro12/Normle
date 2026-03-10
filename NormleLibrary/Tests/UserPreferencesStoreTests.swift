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
    func initCompletesMissingFieldsAndWritesBackNormalizedPayload() throws {
        let userDefaults = makeUserDefaults()
        let payload = """
        {
          "version": 1,
          "maskingPreferences": {
            "isURLMaskingEnabled": false
          },
          "presetSelection": {
            "caseTransform": "uppercase"
          }
        }
        """
        let data = try #require(payload.data(using: .utf8))

        userDefaults.set(
            data,
            forKey: DataAppStorageKey.userPreferences.rawValue
        )

        let store = UserPreferencesStore(userDefaults: userDefaults)

        #expect(store.preferences.maskingPreferences.isURLMaskingEnabled == false)
        #expect(store.preferences.maskingPreferences.isEmailMaskingEnabled)
        #expect(store.preferences.maskingPreferences.isPhoneMaskingEnabled)
        #expect(store.preferences.presetSelection.caseTransform == .uppercase)
        #expect(store.preferences.presetSelection.isCustomMappingEnabled == false)
        #expect(store.preferences.presetSelection.base64Transform == nil)
        let storedData = try #require(
            userDefaults.data(
                forKey: DataAppStorageKey.userPreferences.rawValue
            )
        )
        let storedPreferences = UserPreferences.decode(from: storedData)

        #expect(storedPreferences == store.preferences)
        #expect(storedData != data)
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
                forKey: DataAppStorageKey.userPreferences.rawValue
            )
        )
        let decoded = UserPreferences.decode(from: storedData)

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
