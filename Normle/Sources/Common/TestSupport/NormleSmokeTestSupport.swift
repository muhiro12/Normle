//
//  NormleSmokeTestSupport.swift
//  Normle
//
//  Created by Codex on 2026/03/22.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

#if DEBUG

import Foundation
import MHPlatform
import NormleLibrary
import SwiftData
import SwiftUI

enum NormleSmokeTestSupport {
    @MainActor
    static func makeEnvironment(
        userDefaults: UserDefaults = .standard
    ) -> NormlePlatformEnvironment {
        let modelContainer: ModelContainer

        do {
            modelContainer = try NormleAppModelContainerFactory.makeInMemoryModelContainer()
        } catch {
            preconditionFailure(error.localizedDescription)
        }

        return NormlePlatformEnvironmentFactory.makePreview(
            modelContainer: modelContainer,
            userDefaults: userDefaults
        )
    }

    @MainActor
    static func makeSessionController(
        container: ModelContainer,
        userDefaults: UserDefaults = .standard
    ) -> NormleAppSessionController {
        .init {
            .init(
                platformEnvironment: NormlePlatformEnvironmentFactory.makePreview(
                    modelContainer: container,
                    userDefaults: userDefaults
                ),
                isCloudSyncEnabled: false
            )
        }
    }

    @MainActor
    static func clearPendingRoute(
        in environment: NormlePlatformEnvironment
    ) {
        environment.pendingRouteStore.clear()
    }

    @MainActor
    static func insertSampleHistory(
        in environment: NormlePlatformEnvironment
    ) throws {
        let context = environment.modelContainer.mainContext
        _ = TransformRecord.create(
            context: context,
            sourceText: "alice@example.com",
            targetText: "[Email 1]"
        )
        try context.save()
    }

    @MainActor
    static func insertSampleMapping(
        in environment: NormlePlatformEnvironment
    ) throws {
        let context = environment.modelContainer.mainContext
        _ = try MappingRule.create(
            context: context,
            source: "alice@example.com",
            target: "[Email]"
        )
        try context.save()
    }

    @MainActor
    static func insertSampleTag(
        in environment: NormlePlatformEnvironment
    ) throws {
        let context = environment.modelContainer.mainContext
        _ = try Tag.create(
            context: context,
            name: "Sensitive",
            type: .maskRule
        )
        try context.save()
    }

    @MainActor
    static func historyCount(
        in environment: NormlePlatformEnvironment
    ) throws -> Int {
        let context = environment.modelContainer.mainContext
        return try context.fetchCount(
            FetchDescriptor<TransformRecord>()
        )
    }

    @MainActor
    static func mappingCount(
        in environment: NormlePlatformEnvironment
    ) throws -> Int {
        let context = environment.modelContainer.mainContext
        return try context.fetchCount(
            FetchDescriptor<MappingRule>()
        )
    }

    @MainActor
    static func tagCount(
        in environment: NormlePlatformEnvironment
    ) throws -> Int {
        let context = environment.modelContainer.mainContext
        return try context.fetchCount(
            FetchDescriptor<Tag>()
        )
    }

    @MainActor
    @discardableResult
    static func storePendingRoute(
        _ route: NormleRoute,
        in environment: NormlePlatformEnvironment
    ) -> URL? {
        environment.pendingRouteStore.store(route)
    }

    @MainActor
    static func runtimeHasStarted(
        in environment: NormlePlatformEnvironment
    ) -> Bool {
        environment.runtimeBootstrap.runtime.hasStarted
    }

    @MainActor
    static func activateRuntime(
        in environment: NormlePlatformEnvironment
    ) async {
        let lifecycle = environment.runtimeBootstrap.makeLifecycle()
        await lifecycle.handleInitialAppearance()
        await lifecycle.handleScenePhase(.active)
        await lifecycle.handleScenePhase(.active)
    }

    @MainActor
    static func consumeLatestRoute(
        in environment: NormlePlatformEnvironment
    ) -> NormleRoute? {
        environment.routeInbox.consumeLatest()
    }

    @MainActor
    static func deleteAllHistory(
        in environment: NormlePlatformEnvironment
    ) async throws {
        try await NormleMutationWorkflow.deleteAllHistory(
            context: environment.modelContainer.mainContext
        )
    }
}

#endif
