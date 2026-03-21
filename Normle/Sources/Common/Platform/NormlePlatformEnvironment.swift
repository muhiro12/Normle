//
//  NormlePlatformEnvironment.swift
//  Normle
//
//  Created by Codex on 2026/03/10.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import MHPlatform
import NormleLibrary
import Observation
import SwiftData
import SwiftUI

@MainActor
@Observable
final class NormlePlatformEnvironment {
    let modelContainer: ModelContainer
    let preferencesStore: UserPreferencesStore
    let routeInbox: NormleRouteInbox
    let pendingRouteStore: NormlePendingRouteStore
    let runtimeBootstrap: MHAppRuntimeBootstrap

    init(
        modelContainer: ModelContainer,
        preferencesStore: UserPreferencesStore,
        routeInbox: NormleRouteInbox,
        pendingRouteStore: NormlePendingRouteStore,
        runtimeBootstrap: MHAppRuntimeBootstrap
    ) {
        self.modelContainer = modelContainer
        self.preferencesStore = preferencesStore
        self.routeInbox = routeInbox
        self.pendingRouteStore = pendingRouteStore
        self.runtimeBootstrap = runtimeBootstrap
    }
}

extension View {
    func normlePlatformEnvironment(
        _ environment: NormlePlatformEnvironment
    ) -> some View {
        normleBasePlatformEnvironment(environment)
            .mhAppRuntimeBootstrap(environment.runtimeBootstrap)
    }

    func normlePreviewPlatformEnvironment(
        _ environment: NormlePlatformEnvironment
    ) -> some View {
        normleBasePlatformEnvironment(environment)
            .mhAppRuntimeEnvironment(environment.runtimeBootstrap)
    }

    private func normleBasePlatformEnvironment(
        _ environment: NormlePlatformEnvironment
    ) -> some View {
        modelContainer(environment.modelContainer)
            .environmentObject(environment.preferencesStore)
            .environment(environment)
    }
}
