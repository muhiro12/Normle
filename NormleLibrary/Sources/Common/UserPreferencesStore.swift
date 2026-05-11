//
//  UserPreferencesStore.swift
//  Normle
//
//  Created by Hiromu Nakano on 2025/11/23.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import Combine
import Foundation
import MHPlatformCore

@preconcurrency
@MainActor
public final class UserPreferencesStore: ObservableObject {
    private let preferenceStore: MHPreferenceStore
    private let preferenceKey: MHCodablePreferenceDescriptor<UserPreferences>

    @Published public private(set) var preferences: UserPreferences = .defaults

    public init(
        userDefaults: UserDefaults = .standard
    ) {
        preferenceStore = .init(userDefaults: userDefaults)
        preferenceKey = MHPreferenceDescriptors().userPreferences
        preferences = preferenceStore.codable(for: preferenceKey) ?? .defaults
    }

    public func update(_ mutation: (inout UserPreferences) -> Void) {
        var updatedPreferences = preferences
        mutation(&updatedPreferences)

        guard updatedPreferences != preferences else {
            return
        }

        preferences = updatedPreferences
        preferenceStore.setCodable(
            updatedPreferences,
            for: preferenceKey
        )
    }
}
