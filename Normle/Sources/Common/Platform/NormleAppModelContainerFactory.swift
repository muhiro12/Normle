//
//  NormleAppModelContainerFactory.swift
//  Normle
//
//  Created by Codex on 2026/03/23.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import Foundation
import NormleLibrary
import SwiftData

enum NormleAppModelContainerFactory {
    struct CreationResult {
        let container: ModelContainer
        let isCloudSyncEnabled: Bool
    }

    static func makeAppModelContainer(
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

    static func makePreviewModelContainer() -> ModelContainer {
        makeLiveContainer(
            cloudSyncEnabled: false
        ).container
    }

    static func makeInMemoryModelContainer() throws -> ModelContainer {
        let configuration: ModelConfiguration = .init(
            isStoredInMemoryOnly: true,
            cloudKitDatabase: .none
        )
        return try .init(
            for: TransformRecord.self,
            MappingRule.self,
            Tag.self,
            configurations: configuration
        )
    }

    static func makeLiveContainer(
        cloudSyncEnabled: Bool,
        onCloudContainerError: (Error) -> Void = { _ in
            // Intentionally ignored by default.
        },
        onLocalContainerError: (Error) -> Void = { _ in
            // Intentionally ignored by default.
        }
    ) -> CreationResult {
        makeLiveContainer(
            cloudSyncEnabled: cloudSyncEnabled,
            buildContainer: makeAppModelContainer,
            onCloudContainerError: onCloudContainerError,
            onLocalContainerError: onLocalContainerError
        )
    }

    static func makeLiveContainer(
        cloudSyncEnabled: Bool,
        buildContainer: (Bool) throws -> ModelContainer,
        onCloudContainerError: (Error) -> Void = { _ in
            // Intentionally ignored by default.
        },
        onLocalContainerError: (Error) -> Void = { _ in
            // Intentionally ignored by default.
        }
    ) -> CreationResult {
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
