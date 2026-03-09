//
//  NormleAppAssembly.swift
//  Normle
//
//  Created by Hiromu Nakano on 2026/03/09.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import MHAppRuntimeCore
import MHPreferences
import NormleLibrary
import StoreKitWrapper
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
        _ content: Content
    ) -> some View {
        content
            .modelContainer(modelContainer)
            .environmentObject(preferencesStore)
            .mhAppRuntimeBootstrap(bootstrap)
    }

    func previewRootView<Content: View>(
        _ content: Content
    ) -> some View {
        content
            .modelContainer(modelContainer)
            .environmentObject(preferencesStore)
            .mhAppRuntimeEnvironment(bootstrap)
    }
}

private extension NormleAppAssembly {
    static func makeBootstrap() -> MHAppRuntimeBootstrap {
        .init(
            runtime: makeRuntime(),
            lifecyclePlan: .empty
        )
    }

    static func makeRuntime() -> MHAppRuntime {
        let configuration = MHAppConfiguration(
            subscriptionProductIDs: [Secret.productID],
            subscriptionGroupID: nil,
            nativeAdUnitID: nil,
            preferencesSuiteName: nil,
            showsLicenses: false
        )
        let store = Store()

        return .init(
            configuration: configuration,
            preferenceStore: .init(),
            startStore: { purchasedProductIDsDidSet in
                store.open(
                    groupID: configuration.subscriptionGroupID,
                    productIDs: configuration.subscriptionProductIDs
                ) { products in
                    purchasedProductIDsDidSet(
                        Set(products.map(\.id))
                    )
                }
            },
            subscriptionSectionViewBuilder: {
                AnyView(store.buildSubscriptionSection())
            },
            startAds: nil,
            nativeAdViewBuilder: nil
        ) {
            AnyView(EmptyView())
        }
    }
}
