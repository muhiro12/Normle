//
//  NormleModelContainerFactory.swift
//
//
//  Created by Hiromu Nakano on 2026/02/27.
//

import SwiftData

public struct NormleModelContainerCreationResult {
    public let container: ModelContainer
    public let isCloudSyncEnabled: Bool

    public init(
        container: ModelContainer,
        isCloudSyncEnabled: Bool
    ) {
        self.container = container
        self.isCloudSyncEnabled = isCloudSyncEnabled
    }
}

public enum NormleModelContainerFactory {
    public static func make(
        cloudSyncEnabled: Bool
    ) throws -> ModelContainer {
        try .init(
            for: TransformRecord.self,
            MappingRule.self,
            Tag.self,
            configurations: .init(
                cloudKitDatabase: cloudSyncEnabled ? .automatic : .none
            )
        )
    }

    public static func makeWithFallback(
        cloudSyncEnabled: Bool,
        onCloudContainerError: (Error) -> Void = { _ in },
        onLocalContainerError: (Error) -> Void = { _ in }
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
        onCloudContainerError: (Error) -> Void = { _ in },
        onLocalContainerError: (Error) -> Void = { _ in }
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
