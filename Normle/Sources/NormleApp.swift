//
//  NormleApp.swift
//  Normle
//
//  Created by Hiromu Nakano on 2025/11/23.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import MHLogging
import MHPreferences
import NormleLibrary
import SwiftUI

@main
struct NormleApp: App {
    @AppStorage(BoolAppStorageKey.isICloudOn)
    private var isICloudOn

    private let assembly: NormleAppAssembly

    var body: some Scene {
        WindowGroup {
            assembly.rootView(
                ContentView()
                    .id(isICloudOn)
            )
        }
    }

    init() {
        assembly = .live()
        isICloudOn = assembly.isCloudSyncEnabled
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
}
