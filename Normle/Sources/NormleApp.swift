//
//  NormleApp.swift
//  Normle
//
//  Created by Hiromu Nakano on 2025/11/23.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import NormleLibrary
import StoreKitWrapper
import SwiftData
import SwiftUI

@main
struct NormleApp: App {
    @AppStorage(.isICloudOn)
    private var isICloudOn
    @StateObject private var preferencesStore = UserPreferencesStore()

    private let sharedModelContainer: ModelContainer
    private let sharedStore: Store

    var body: some Scene {
        WindowGroup {
            ContentView()
                .id(isICloudOn)
                .modelContainer(sharedModelContainer)
                .environment(sharedStore)
                .environmentObject(preferencesStore)
        }
    }

    init() {
        sharedStore = .init()
        let isCloudSyncEnabled = UserDefaults.standard.bool(
            forKey: BoolAppStorageKey.isICloudOn.rawValue
        )
        let result = NormleModelContainerFactory.makeWithFallback(
            cloudSyncEnabled: isCloudSyncEnabled
        ) { error in
            assertionFailure(error.localizedDescription)
        } onLocalContainerError: { error in
            assertionFailure(error.localizedDescription)
        }
        sharedModelContainer = result.container
        isICloudOn = result.isCloudSyncEnabled
    }
}
