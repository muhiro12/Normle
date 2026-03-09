//
//  NormleApp.swift
//  Normle
//
//  Created by Hiromu Nakano on 2025/11/23.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import NormleLibrary
import StoreKitWrapper
import SwiftUI

@main
struct NormleApp: App {
    @AppStorage(.isICloudOn)
    private var isICloudOn

    private let assembly: NormleAppAssembly
    private let sharedStore: Store

    var body: some Scene {
        WindowGroup {
            assembly.rootView(
                ContentView()
                    .id(isICloudOn)
            )
            .environment(sharedStore)
        }
    }

    init() {
        sharedStore = .init()
        assembly = .live()
        isICloudOn = assembly.isCloudSyncEnabled
    }
}
