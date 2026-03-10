//
//  NormleModelContainerFactory.swift
//  Normle
//
//  Created by Hiromu Nakano on 2026/02/27.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import SwiftData

/// Builds SwiftData model containers for the app.
public enum NormleModelContainerFactory {
    /// Creates a model container with the requested cloud sync setting.
    public static func make(
        cloudSyncEnabled: Bool
    ) throws -> ModelContainer {
        try .init(
            for: Schema(NormleSchemaV1.models),
            migrationPlan: NormleSchemaMigrationPlan.self,
            configurations: .init(
                cloudKitDatabase: cloudSyncEnabled ? .automatic : .none
            )
        )
    }

    /// Creates a model container and falls back to local storage if cloud setup fails.
    public static func makeWithFallback(
        cloudSyncEnabled: Bool,
        onCloudContainerError: (Error) -> Void = { _ in
            // Intentionally ignored by default.
        },
        onLocalContainerError: (Error) -> Void = { _ in
            // Intentionally ignored by default.
        }
    ) -> NormleModelContainerCreationResult {
        makeWithFallback(
            cloudSyncEnabled: cloudSyncEnabled,
            buildContainer: make,
            onCloudContainerError: onCloudContainerError,
            onLocalContainerError: onLocalContainerError
        )
    }

    static func makeWithFallback(
        cloudSyncEnabled: Bool,
        buildContainer: (Bool) throws -> ModelContainer,
        onCloudContainerError: (Error) -> Void = { _ in
            // Intentionally ignored by default.
        },
        onLocalContainerError: (Error) -> Void = { _ in
            // Intentionally ignored by default.
        }
    ) -> NormleModelContainerCreationResult {
        do {
            return .init(
                container: try buildContainer(cloudSyncEnabled),
                isCloudSyncEnabled: cloudSyncEnabled
            )
        } catch {
            if cloudSyncEnabled {
                onCloudContainerError(error)
                do {
                    return .init(
                        container: try buildContainer(false),
                        isCloudSyncEnabled: false
                    )
                } catch {
                    onLocalContainerError(error)
                    fatalError(error.localizedDescription)
                }
            }

            onLocalContainerError(error)
            fatalError(error.localizedDescription)
        }
    }
}
