//
//  NormleApp.swift
//  Normle
//
//  Created by Hiromu Nakano on 2025/11/23.
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

    private var sharedModelContainer: ModelContainer!
    private var sharedStore: Store

    init() {
        sharedStore = .init()
        let result = NormleModelContainerFactory.makeWithFallback(
            cloudSyncEnabled: isICloudOn
        ) { error in
            assertionFailure(error.localizedDescription)
        } onLocalContainerError: { error in
            assertionFailure(error.localizedDescription)
        }
        sharedModelContainer = result.container
        isICloudOn = result.isCloudSyncEnabled
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .id(isICloudOn)
                .modelContainer(sharedModelContainer)
                .environment(sharedStore)
                .environmentObject(preferencesStore)
        }
    }
}
