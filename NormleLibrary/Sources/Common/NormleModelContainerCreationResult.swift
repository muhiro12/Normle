//
//  NormleModelContainerCreationResult.swift
//  Normle
//
//  Created by Hiromu Nakano on 2026/03/03.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import SwiftData

/// Describes a created model container and its cloud sync state.
public struct NormleModelContainerCreationResult {
    /// The created model container.
    public let container: ModelContainer
    /// Indicates whether cloud sync remains enabled for the created container.
    public let isCloudSyncEnabled: Bool

    /// Creates a model container creation result.
    public init(
        container: ModelContainer,
        isCloudSyncEnabled: Bool
    ) {
        self.container = container
        self.isCloudSyncEnabled = isCloudSyncEnabled
    }
}
