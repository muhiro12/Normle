//
//  NormlePlatformEnvironmentFactory.swift
//  Normle
//
//  Created by Codex on 2026/03/10.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import MHPlatform
import NormleLibrary
import SwiftData

enum NormlePlatformEnvironmentFactory {
    @MainActor
    static func make(
        modelContainer: ModelContainer
    ) -> NormlePlatformEnvironment {
        let preferencesStore = UserPreferencesStore()
        let routeInbox = makeRouteInbox()
        let pendingRouteStore = NormlePendingRouteStore()

        return .init(
            modelContainer: modelContainer,
            preferencesStore: preferencesStore,
            routeInbox: routeInbox,
            pendingRouteStore: pendingRouteStore,
            runtimeBootstrap: makeRuntimeBootstrap(
                configuration: makeAppConfiguration(),
                routeInbox: routeInbox,
                pendingRouteStore: pendingRouteStore
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
            subscriptionGroupID: nil,
            nativeAdUnitID: NormleAdMobConfiguration.nativeAdUnitID,
            preferencesSuiteName: nil,
            showsLicenses: true
        )
    }

    @MainActor
    private static func makeRuntimeBootstrap(
        configuration: MHAppConfiguration,
        routeInbox: NormleRouteInbox,
        pendingRouteStore: NormlePendingRouteStore
    ) -> MHAppRuntimeBootstrap {
        let reviewFlow = NormleReviewSupport.flow(
            context: .appActivation,
            source: #fileID
        )
        let routePipeline = MHAppRoutePipeline(
            routeLifecycle: .init(
                logger: NormleApp.logger(
                    category: "Routing",
                    source: #fileID
                ),
                isDuplicate: ==
            ),
            using: NormleRouteCodec.deepLink,
            routeInbox: routeInbox,
            pendingSources: [
                pendingRouteStore.source
            ]
        )

        return .init(
            configuration: configuration,
            lifecyclePlan: .init(
                activeTasks: [
                    routePipeline.task(
                        name: "synchronizePendingRoutes"
                    ),
                    reviewFlow.task(name: "requestReview")
                ],
                skipFirstActivePhase: true
            ),
            routePipeline: routePipeline
        )
    }

    @MainActor
    private static func makeRouteInbox() -> NormleRouteInbox {
        .init(
            isDuplicate: ==
        )
    }
}
