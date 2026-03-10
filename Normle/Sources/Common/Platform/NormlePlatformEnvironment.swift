//
//  NormlePlatformEnvironment.swift
//  Normle
//
//  Created by Codex on 2026/03/10.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import MHAppRuntimeCore
import NormleLibrary
import SwiftData
import SwiftUI

struct NormlePlatformEnvironment {
    let modelContainer: ModelContainer
    let preferencesStore: UserPreferencesStore
    let runtimeBootstrap: MHAppRuntimeBootstrap
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
    }
}
