//
//  NormleSmokeTests.swift
//  NormleTests
//
//  Created by Codex on 2026/03/22.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import Foundation
import MHPlatform
import NormleLibrary
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

    @Test
    func factoryResetClearsPersistedStateAndRebuildsAppSession() async throws {
        let suiteName = "NormleSmokeTests.\(UUID().uuidString)"
        guard let userDefaults = UserDefaults(
            suiteName: suiteName
        ) else {
            Issue.record("Failed to create isolated user defaults")
            return
        }

        userDefaults.removePersistentDomain(
            forName: suiteName
        )
        defer {
            userDefaults.removePersistentDomain(
                forName: suiteName
            )
        }

        let environment = NormleSmokeTestSupport.makeEnvironment(
            userDefaults: userDefaults
        )
        let sessionController = NormleSmokeTestSupport.makeSessionController(
            container: environment.modelContainer,
            userDefaults: userDefaults
        )
        let coordinator = NormleFactoryResetCoordinator()

        try seedFactoryResetState(
            in: environment,
            userDefaults: userDefaults
        )

        await coordinator.run(
            context: environment.modelContainer.mainContext,
            preferencesStore: environment.preferencesStore,
            pendingRouteStore: environment.pendingRouteStore,
            sessionController: sessionController,
            userDefaults: userDefaults
        )

        try expectFactoryResetCleanup(
            in: environment,
            userDefaults: userDefaults,
            sessionController: sessionController,
            coordinator: coordinator
        )
    }

    @Test
    func factoryResetFailurePresentsLocalizedAlert() async throws {
        let suiteName = "NormleSmokeTests.\(UUID().uuidString)"
        guard let userDefaults = UserDefaults(
            suiteName: suiteName
        ) else {
            Issue.record("Failed to create isolated user defaults")
            return
        }

        userDefaults.removePersistentDomain(
            forName: suiteName
        )
        defer {
            userDefaults.removePersistentDomain(
                forName: suiteName
            )
        }

        struct SampleError: LocalizedError, Sendable {
            var errorDescription: String? {
                "Sample failure"
            }
        }

        let environment = NormleSmokeTestSupport.makeEnvironment(
            userDefaults: userDefaults
        )
        let sessionController = NormleSmokeTestSupport.makeSessionController(
            container: environment.modelContainer,
            userDefaults: userDefaults
        )
        let coordinator = NormleFactoryResetCoordinator()
        try NormleSmokeTestSupport.insertSampleHistory(
            in: environment
        )

        await coordinator.run(
            context: environment.modelContainer.mainContext,
            preferencesStore: environment.preferencesStore,
            pendingRouteStore: environment.pendingRouteStore,
            sessionController: sessionController,
            userDefaults: userDefaults,
            destructiveReset: makeFactoryResetFailureRunner(
                error: SampleError()
            )
        )

        try expectFactoryResetFailureState(
            in: environment,
            sessionController: sessionController,
            coordinator: coordinator
        )
    }
}

private extension NormleSmokeTests {
    var persistedFlagKeys: [BoolAppStorageKey] {
        [
            .isSubscribeOn,
            .isICloudOn,
            .isURLMaskingEnabled,
            .isEmailMaskingEnabled,
            .isPhoneMaskingEnabled
        ]
    }

    func seedFactoryResetState(
        in environment: NormlePlatformEnvironment,
        userDefaults: UserDefaults
    ) throws {
        try NormleSmokeTestSupport.insertSampleHistory(
            in: environment
        )
        try NormleSmokeTestSupport.insertSampleMapping(
            in: environment
        )
        try NormleSmokeTestSupport.insertSampleTag(
            in: environment
        )

        environment.preferencesStore.update { preferences in
            preferences.maskingPreferences = .init(
                isURLMaskingEnabled: false,
                isEmailMaskingEnabled: false,
                isPhoneMaskingEnabled: false
            )
            preferences.presetSelection = .init(
                isCustomMappingEnabled: true,
                caseTransform: .uppercase,
                alphanumericWidthTransform: .halfwidthAlphanumericToFullwidth,
                spaceWidthTransform: nil,
                katakanaWidthTransform: nil,
                digitsWidthTransform: nil,
                base64Transform: nil,
                urlTransform: nil,
                qrTransform: nil
            )
        }

        persistedFlagKeys.forEach { key in
            userDefaults.set(
                true,
                forKey: key.preferenceKey.storageKey
            )
        }

        #expect(
            NormleSmokeTestSupport.storePendingRoute(
                .settings,
                in: environment
            ) != nil
        )
        #expect(
            environment.preferencesStore.preferences != .defaults
        )
        #expect(
            userDefaults.data(
                forKey: DataAppStorageKey.userPreferences.preferenceKey.storageKey
            ) != nil
        )
    }

    func expectFactoryResetCleanup(
        in environment: NormlePlatformEnvironment,
        userDefaults: UserDefaults,
        sessionController: NormleAppSessionController,
        coordinator: NormleFactoryResetCoordinator
    ) throws {
        #expect(
            try NormleSmokeTestSupport.historyCount(
                in: environment
            ) == 0
        )
        #expect(
            try NormleSmokeTestSupport.mappingCount(
                in: environment
            ) == 0
        )
        #expect(
            try NormleSmokeTestSupport.tagCount(
                in: environment
            ) == 0
        )
        #expect(environment.preferencesStore.preferences == .defaults)
        #expect(
            userDefaults.data(
                forKey: DataAppStorageKey.userPreferences.preferenceKey.storageKey
            ) == nil
        )

        persistedFlagKeys.forEach { key in
            #expect(
                userDefaults.object(
                    forKey: key.preferenceKey.storageKey
                ) == nil
            )
        }
        #expect(
            userDefaults.bool(
                forKey: BoolAppStorageKey.shouldResetTipsOnNextLaunch.preferenceKey.storageKey
            )
        )

        #expect(
            environment.pendingRouteStore.consumeLatestRoute() == nil
        )
        #expect(sessionController.revision == 1)
        #expect(coordinator.isRunning == false)
        #expect(coordinator.activeStepDescription == nil)

        let pendingAlert = sessionController.consumePendingAlert()
        #expect(
            pendingAlert?.title == String(
                localized: "Factory reset complete"
            )
        )
        #expect(
            pendingAlert?.message == String(
                localized: "Normle returned to a clean local state on this device."
            )
        )
    }

    func makeFactoryResetFailureRunner(
        error: some LocalizedError & Sendable
    ) -> (
        [MHDestructiveResetStep],
        @escaping @Sendable (MHDestructiveResetEvent) -> Void
    ) async -> MHDestructiveResetOutcome {
        { _, onEvent in
            onEvent(
                .stepStarted(name: "clearPersistedModels")
            )
            onEvent(
                .stepFailed(
                    name: "clearPersistedModels",
                    message: error.localizedDescription
                )
            )
            return .failed(
                error: error,
                failedStep: "clearPersistedModels",
                completedSteps: ["clearPendingRoutes"]
            )
        }
    }

    func expectFactoryResetFailureState(
        in environment: NormlePlatformEnvironment,
        sessionController: NormleAppSessionController,
        coordinator: NormleFactoryResetCoordinator
    ) throws {
        #expect(
            try NormleSmokeTestSupport.historyCount(
                in: environment
            ) == 1
        )
        #expect(sessionController.revision == 0)
        #expect(coordinator.isRunning == false)
        #expect(coordinator.activeStepDescription == nil)

        let pendingAlert = sessionController.consumePendingAlert()
        #expect(
            pendingAlert?.title == String(
                localized: "Factory reset failed"
            )
        )
        #expect(
            pendingAlert?.message == String.localizedStringWithFormat(
                String(localized: "%@ failed: %@"),
                String(localized: "Deleting local data"),
                "Sample failure"
            )
        )
    }
}
