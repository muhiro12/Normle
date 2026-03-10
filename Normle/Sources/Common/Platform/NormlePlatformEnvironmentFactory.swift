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
            subscriptionGroupID: nil,
            nativeAdUnitID: NormleAdMobConfiguration.nativeAdUnitID,
            preferencesSuiteName: nil,
            showsLicenses: true
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
            configuration: configuration,
            lifecyclePlan: .init(
                activeTasks: [
                    reviewFlow.task(name: "requestReview")
                ]
            )
        )
    }
}
