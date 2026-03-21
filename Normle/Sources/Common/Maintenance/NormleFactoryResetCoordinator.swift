//
//  NormleFactoryResetCoordinator.swift
//  Normle
//
//  Created by Codex on 2026/03/21.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import Foundation
import MHPlatform
import NormleLibrary
import Observation
import SwiftData

@MainActor
@Observable
final class NormleFactoryResetCoordinator {
    private final class Dependencies: @unchecked Sendable {
        let context: ModelContext
        let preferencesStore: UserPreferencesStore
        let preferenceStore: MHPreferenceStore
        let pendingRouteStore: NormlePendingRouteStore
        let sessionController: NormleAppSessionController

        init(
            context: ModelContext,
            preferencesStore: UserPreferencesStore,
            preferenceStore: MHPreferenceStore,
            pendingRouteStore: NormlePendingRouteStore,
            sessionController: NormleAppSessionController
        ) {
            self.context = context
            self.preferencesStore = preferencesStore
            self.preferenceStore = preferenceStore
            self.pendingRouteStore = pendingRouteStore
            self.sessionController = sessionController
        }
    }

    private enum StepName {
        static let clearPendingRoutes = "clearPendingRoutes"
        static let clearPersistedModels = "clearPersistedModels"
        static let resetPreferences = "resetPreferences"
        static let clearAppFlags = "clearAppFlags"
        static let resetTips = "resetTips"
        static let rebuildAppSession = "rebuildAppSession"
    }

    private(set) var isRunning = false
    private(set) var activeStepDescription: String?

    func run(
        context: ModelContext,
        preferencesStore: UserPreferencesStore,
        pendingRouteStore: NormlePendingRouteStore,
        sessionController: NormleAppSessionController,
        userDefaults: UserDefaults = .standard
    ) async {
        guard isRunning == false else {
            return
        }

        isRunning = true
        activeStepDescription = nil

        let preferenceStore = MHPreferenceStore(
            userDefaults: userDefaults
        )
        let dependencies = Dependencies(
            context: context,
            preferencesStore: preferencesStore,
            preferenceStore: preferenceStore,
            pendingRouteStore: pendingRouteStore,
            sessionController: sessionController
        )

        let outcome = await MHDestructiveResetService.run(
            steps: makeSteps(
                dependencies: dependencies
            )
        ) { event in
            Task { @MainActor in
                self.apply(event: event)
            }
        }

        isRunning = false
        activeStepDescription = nil

        switch outcome {
        case .succeeded:
            sessionController.presentAlert(
                title: "Factory reset complete",
                message: "Normle returned to a clean local state on this device."
            )
        case let .failed(error, failedStep, _):
            sessionController.presentAlert(
                title: "Factory reset failed",
                message: "\(displayName(for: failedStep)) failed: \(error.localizedDescription)"
            )
        }
    }
}

private extension NormleFactoryResetCoordinator {
    private func makeSteps(
        dependencies: Dependencies
    ) -> [MHDestructiveResetStep] {
        [
            .init(name: StepName.clearPendingRoutes) {
                await MainActor.run {
                    dependencies.pendingRouteStore.clear()
                }
            },
            .init(name: StepName.clearPersistedModels) {
                try await MainActor.run {
                    try self.deleteAllModels(
                        context: dependencies.context
                    )
                }
            },
            .init(name: StepName.resetPreferences) {
                await MainActor.run {
                    dependencies.preferencesStore.update { preferences in
                        preferences = .defaults
                    }
                    dependencies.preferenceStore.remove(
                        DataAppStorageKey.userPreferences.preferenceKey
                    )
                }
            },
            .init(name: StepName.clearAppFlags) {
                await MainActor.run {
                    self.clearAppFlags(
                        preferenceStore: dependencies.preferenceStore
                    )
                }
            },
            .init(name: StepName.resetTips) {
                try await MainActor.run {
                    try NormleTipManager.reset()
                }
            },
            .init(name: StepName.rebuildAppSession) {
                await MainActor.run {
                    _ = dependencies.sessionController.rebuild()
                }
            }
        ]
    }

    func apply(
        event: MHDestructiveResetEvent
    ) {
        switch event {
        case .stepStarted(let name):
            activeStepDescription = displayName(for: name)
        case .stepSucceeded:
            return
        case .stepFailed(let name, _):
            activeStepDescription = displayName(for: name)
        case .completed:
            activeStepDescription = nil
        }
    }

    func displayName(
        for stepName: String
    ) -> String {
        switch stepName {
        case StepName.clearPendingRoutes:
            return "Clearing pending deep links"
        case StepName.clearPersistedModels:
            return "Deleting local data"
        case StepName.resetPreferences:
            return "Resetting preferences"
        case StepName.clearAppFlags:
            return "Clearing app flags"
        case StepName.resetTips:
            return "Resetting tips"
        case StepName.rebuildAppSession:
            return "Rebuilding app session"
        default:
            return stepName
        }
    }

    func deleteAllModels(
        context: ModelContext
    ) throws {
        try deleteAll(
            of: TransformRecord.self,
            context: context
        )
        try deleteAll(
            of: MappingRule.self,
            context: context
        )
        try deleteAll(
            of: Tag.self,
            context: context
        )
        try context.save()
    }

    func deleteAll<Model: PersistentModel>(
        of _: Model.Type,
        context: ModelContext
    ) throws {
        let descriptor = FetchDescriptor<Model>()
        try context.fetch(descriptor).forEach { model in
            context.delete(model)
        }
    }

    func clearAppFlags(
        preferenceStore: MHPreferenceStore
    ) {
        [
            BoolAppStorageKey.isSubscribeOn,
            BoolAppStorageKey.isICloudOn,
            BoolAppStorageKey.isURLMaskingEnabled,
            BoolAppStorageKey.isEmailMaskingEnabled,
            BoolAppStorageKey.isPhoneMaskingEnabled
        ].forEach { key in
            preferenceStore.remove(
                key.preferenceKey
            )
        }
    }
}
