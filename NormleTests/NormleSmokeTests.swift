//
//  NormleSmokeTests.swift
//  NormleTests
//
//  Created by Codex on 2026/03/22.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import Testing

@testable import Normle

@MainActor
struct NormleSmokeTests {
    @Test
    func runtimeBootstrapDeliversPendingRouteAndMutationWorkflowDeletesHistory() async throws {
        let environment = NormleSmokeTestSupport.makeEnvironment()

        NormleSmokeTestSupport.clearPendingRoute(
            in: environment
        )
        defer {
            NormleSmokeTestSupport.clearPendingRoute(
                in: environment
            )
        }

        try NormleSmokeTestSupport.insertSampleHistory(
            in: environment
        )

        #expect(
            NormleSmokeTestSupport.runtimeHasStarted(
                in: environment
            ) == false
        )
        #expect(
            NormleSmokeTestSupport.storePendingRoute(
                .settings,
                in: environment
            ) != nil
        )

        await NormleSmokeTestSupport.activateRuntime(
            in: environment
        )

        #expect(
            NormleSmokeTestSupport.runtimeHasStarted(
                in: environment
            )
        )
        #expect(
            NormleSmokeTestSupport.consumeLatestRoute(
                in: environment
            ) == .settings
        )

        try await NormleSmokeTestSupport.deleteAllHistory(
            in: environment
        )

        let historyCount = try NormleSmokeTestSupport.historyCount(
            in: environment
        )
        #expect(historyCount == 0)
    }
}
