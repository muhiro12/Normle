//
//  NormleAppAssembly.swift
//  Normle
//
//  Created by Hiromu Nakano on 2026/03/09.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import MHPlatform
import NormleLibrary
import SwiftData
import SwiftUI

@MainActor
struct NormleAppAssembly {
    let modelContainer: ModelContainer
    let preferencesStore: UserPreferencesStore
    let bootstrap: MHAppRuntimeBootstrap
    let isCloudSyncEnabled: Bool

    static func live() -> Self {
        let result = NormleModelContainerFactory.makeWithFallback(
            cloudSyncEnabled: UserDefaults.standard.bool(
                forKey: BoolAppStorageKey.isICloudOn.rawValue
            )
        ) { error in
            assertionFailure(error.localizedDescription)
        } onLocalContainerError: { error in
            assertionFailure(error.localizedDescription)
        }

        return .init(
            modelContainer: result.container,
            preferencesStore: .init(),
            bootstrap: makeBootstrap(),
            isCloudSyncEnabled: result.isCloudSyncEnabled
        )
    }

    static func preview(
        container: ModelContainer = PreviewData.makeContainer()
    ) -> Self {
        .init(
            modelContainer: container,
            preferencesStore: .init(),
            bootstrap: makeBootstrap(),
            isCloudSyncEnabled: false
        )
    }

    @ViewBuilder
    func rootView<Content: View>(
        _ content: Content,
        applyRuntimeBootstrap: Bool = true
    ) -> some View {
        if applyRuntimeBootstrap {
            content
                .modelContainer(modelContainer)
                .environmentObject(preferencesStore)
                .mhAppRuntimeBootstrap(bootstrap)
        } else {
            content
                .modelContainer(modelContainer)
                .environmentObject(preferencesStore)
                .environment(bootstrap.runtime)
        }
    }
}

private extension NormleAppAssembly {
    static func makeBootstrap() -> MHAppRuntimeBootstrap {
        .init(
            configuration: .init(
                subscriptionProductIDs: [Secret.productID],
                subscriptionGroupID: nil,
                nativeAdUnitID: nil,
                preferencesSuiteName: nil,
                showsLicenses: false
            ),
            lifecyclePlan: .empty
        )
    }
}
