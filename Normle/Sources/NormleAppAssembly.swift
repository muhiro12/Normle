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
    let platformEnvironment: NormlePlatformEnvironment
    let isCloudSyncEnabled: Bool

    static func live() -> Self {
        let isCloudSyncEnabled = MHPreferenceStore().bool(
            for: BoolAppStorageKey.isICloudOn.preferenceKey
        )
        let result = NormleModelContainerFactory.makeWithFallback(
            cloudSyncEnabled: isCloudSyncEnabled,
            onCloudContainerError: { error in
                assertionFailure(error.localizedDescription)
            },
            onLocalContainerError: { error in
                assertionFailure(error.localizedDescription)
            }
        )

        return .init(
            platformEnvironment: NormlePlatformEnvironmentFactory.make(
                modelContainer: result.container
            ),
            isCloudSyncEnabled: result.isCloudSyncEnabled
        )
    }

    static func preview(
        container: ModelContainer = PreviewData.makeContainer()
    ) -> Self {
        .init(
            platformEnvironment: NormlePlatformEnvironmentFactory.makePreview(
                modelContainer: container
            ),
            isCloudSyncEnabled: false
        )
    }

    @ViewBuilder
    func rootView<Content: View>(
        _ content: Content
    ) -> some View {
        content.normlePlatformEnvironment(platformEnvironment)
    }

    func previewRootView<Content: View>(
        _ content: Content
    ) -> some View {
        content.normlePreviewPlatformEnvironment(platformEnvironment)
    }
}
