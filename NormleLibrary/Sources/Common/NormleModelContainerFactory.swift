//
//  NormleModelContainerFactory.swift
//
//
//  Created by Hiromu Nakano on 2026/02/27.
//

import SwiftData

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

    public static func makeInMemory() throws -> ModelContainer {
        try .init(
            for: TransformRecord.self,
            MappingRule.self,
            Tag.self,
            configurations: .init(
                isStoredInMemoryOnly: true
            )
        )
    }

    public static func makeWithFallback(
        cloudSyncEnabled: Bool,
        onPrimaryError: (Error) -> Void = { _ in }
    ) -> ModelContainer {
        do {
            return try make(cloudSyncEnabled: cloudSyncEnabled)
        } catch {
            onPrimaryError(error)
            do {
                return try makeInMemory()
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }
}
