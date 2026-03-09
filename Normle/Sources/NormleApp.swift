//
//  NormleApp.swift
//  Normle
//
//  Created by Hiromu Nakano on 2025/11/23.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import NormleLibrary
import SwiftUI

@main
struct NormleApp: App {
    @AppStorage(.isICloudOn)
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
