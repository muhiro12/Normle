//
//  SettingsScreenModel.swift
//  Normle
//
//  Created by Codex on 2026/03/23.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import Foundation
import NormleLibrary
import Observation
import SwiftData

@MainActor
@Observable
final class SettingsScreenModel {
    let factoryResetCoordinator = NormleFactoryResetCoordinator()

    var alertTitle = String()
    var alertMessage = String()

    var isShowingAlert: Bool {
        alertMessage.isEmpty == false
    }

    func deleteAllHistory(
        context: ModelContext
    ) async {
        do {
            try await NormleMutationWorkflow.deleteAllHistory(
                context: context
            )
        } catch {
            presentError(
                message: error.localizedDescription
            )
        }
    }

    func runFactoryReset(
        context: ModelContext,
        preferencesStore: UserPreferencesStore,
        pendingRouteStore: NormlePendingRouteStore,
        sessionController: NormleAppSessionController
    ) async {
        await factoryResetCoordinator.run(
            context: context,
            preferencesStore: preferencesStore,
            pendingRouteStore: pendingRouteStore,
            sessionController: sessionController
        )
    }

    func resetTips(
        userDefaults: UserDefaults = .standard
    ) {
        NormleTipManager.scheduleReset(
            userDefaults: userDefaults
        )
        alertTitle = String(localized: "Tips reset")
        alertMessage = String(
            localized: "Close and reopen Normle to show tips again."
        )
    }

    func dismissAlert() {
        alertTitle = String()
        alertMessage = String()
    }
}

private extension SettingsScreenModel {
    func presentError(
        message: String
    ) {
        alertTitle = String(localized: "Error")
        alertMessage = message
    }
}
