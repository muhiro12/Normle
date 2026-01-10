//
//  UserPreferencesStore.swift
//
//
//  Created by Hiromu Nakano on 2025/11/23.
//

import Combine
import NormleLibrary
import SwiftUI

@MainActor
final class UserPreferencesStore: ObservableObject {
    @AppStorage(.userPreferences)
    private var storedData = Data()

    @Published private(set) var preferences: UserPreferences = .defaults

    init() {
        preferences = UserPreferences.decode(from: storedData)
    }

    func update(_ mutation: (inout UserPreferences) -> Void) {
        var updatedPreferences = preferences
        mutation(&updatedPreferences)
        guard updatedPreferences != preferences else {
            return
        }
        preferences = updatedPreferences
        storedData = updatedPreferences.encode()
    }
}
