//
//  NormlePlatformEnvironmentFactory.swift
//  Normle
//
//  Created by Codex on 2026/03/10.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import MHAppRuntimeCore
import MHPreferences
import MHReviewPolicy
import NormleLibrary
import StoreKitWrapper
import SwiftData
import SwiftUI

enum NormlePlatformEnvironmentFactory {
    @MainActor
    static func make(
        modelContainer: ModelContainer
    ) -> NormlePlatformEnvironment {
        .init(
            modelContainer: modelContainer,
            preferencesStore: .init(),
            runtimeBootstrap: makeRuntimeBootstrap(
                configuration: makeAppConfiguration()
            )
        )
    }

    @MainActor
    static func makePreview(
        modelContainer: ModelContainer
    ) -> NormlePlatformEnvironment {
        make(modelContainer: modelContainer)
    }

    private static func makeAppConfiguration() -> MHAppConfiguration {
        .init(
            subscriptionProductIDs: [Secret.productID],
            showsLicenses: false
        )
    }

    @MainActor
    private static func makeRuntimeBootstrap(
        configuration: MHAppConfiguration
    ) -> MHAppRuntimeBootstrap {
        let reviewFlow = NormleReviewSupport.flow(
            context: .appActivation,
            source: #fileID
        )

        return .init(
            runtime: makeRuntime(configuration: configuration),
            lifecyclePlan: .init(
                activeTasks: [
                    reviewFlow.task(name: "requestReview")
                ]
            )
        )
    }

    @MainActor
    private static func makeRuntime(
        configuration: MHAppConfiguration
    ) -> MHAppRuntime {
        let store = Store()
        let licensesViewBuilder = {
            AnyView(EmptyView())
        }

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
            nativeAdViewBuilder: nil,
            licensesViewBuilder: licensesViewBuilder
        )
    }
}
