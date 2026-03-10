//
//  UserPreferencesStore.swift
//  Normle
//
//  Created by Hiromu Nakano on 2025/11/23.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import Combine
import Foundation
import MHPlatform

@preconcurrency
@MainActor
public final class UserPreferencesStore: ObservableObject {
    private let preferenceStore: MHPreferenceStore
    private let preferenceKey: MHCodablePreferenceKey<UserPreferences>

    @Published public private(set) var preferences: UserPreferences = .defaults

    public init(
        userDefaults: UserDefaults = .standard
    ) {
        preferenceStore = .init(userDefaults: userDefaults)
        preferenceKey = DataAppStorageKey.userPreferences.preferenceKey
        preferences = Self.loadPreferences(
            userDefaults: userDefaults,
            preferenceStore: preferenceStore,
            preferenceKey: preferenceKey
        )
    }

    public func update(_ mutation: (inout UserPreferences) -> Void) {
        var updatedPreferences = preferences
        mutation(&updatedPreferences)
        let normalizedPreferences = updatedPreferences.normalized()

        guard normalizedPreferences != preferences else {
            return
        }

        preferences = normalizedPreferences
        preferenceStore.setCodable(
            normalizedPreferences,
            for: preferenceKey
        )
    }
}

private extension UserPreferencesStore {
    static func loadPreferences(
        userDefaults: UserDefaults,
        preferenceStore: MHPreferenceStore,
        preferenceKey: MHCodablePreferenceKey<UserPreferences>
    ) -> UserPreferences {
        guard let storedData = userDefaults.data(
            forKey: preferenceKey.storageKey
        ) else {
            return .defaults
        }

        let preferences: UserPreferences

        if let storedPreferences = preferenceStore.codable(
            for: preferenceKey
        ) {
            preferences = storedPreferences.normalized()
        } else {
            preferences = UserPreferences.decode(from: storedData)
        }

        guard preferences.encode() != storedData else {
            return preferences
        }

        preferenceStore.setCodable(
            preferences,
            for: preferenceKey
        )
        return preferences
    }
}
