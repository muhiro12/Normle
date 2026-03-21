//
//  NormleApp.swift
//  Normle
//
//  Created by Hiromu Nakano on 2025/11/23.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import MHPlatform
import NormleLibrary
import Observation
import SwiftUI

@main
struct NormleApp: App {
    @AppStorage(BoolAppStorageKey.isICloudOn)
    private var isICloudOn

    @State private var sessionController: NormleAppSessionController

    var body: some Scene {
        WindowGroup {
            sessionController.assembly.rootView(
                ContentView()
                    .id(sessionController.revision),
                sessionController: sessionController
            )
            .task(id: isICloudOn) {
                synchronizeAppSession()
            }
        }
    }

    init() {
        let sessionController = NormleAppSessionController.live()
        _sessionController = State(
            initialValue: sessionController
        )
        isICloudOn = sessionController.cloudSyncEnabled
        NormleTipManager.configure()
    }
}

extension NormleApp {
    nonisolated static let loggerFactory = MHLoggerFactory.osLogDefault

    nonisolated static func logger(
        category: String,
        source: String = #fileID
    ) -> MHLogger {
        loggerFactory.logger(
            category: category,
            source: source
        )
    }

    @MainActor
    private func synchronizeAppSession() {
        let actualCloudSyncEnabled = sessionController.rebuildIfNeeded(
            for: isICloudOn
        )

        if actualCloudSyncEnabled != isICloudOn {
            isICloudOn = actualCloudSyncEnabled
        }
    }
}
