//
//  NormleSmokeTestSupport.swift
//  Normle
//
//  Created by Codex on 2026/03/22.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

#if DEBUG

import MHAppRuntimeCore
import MHRouteExecution
import NormleLibrary
import SwiftData
import SwiftUI

enum NormleSmokeTestSupport {
    @MainActor
    static func makeEnvironment() -> NormlePlatformEnvironment {
        NormleAppAssembly.smokeTest().platformEnvironment
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
    static func historyCount(
        in environment: NormlePlatformEnvironment
    ) throws -> Int {
        let context = environment.modelContainer.mainContext
        return try context.fetchCount(
            FetchDescriptor<TransformRecord>()
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
