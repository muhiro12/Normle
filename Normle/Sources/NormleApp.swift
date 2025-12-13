//
//  NormleApp.swift
//  Normle
//
//  Created by Hiromu Nakano on 2025/11/23.
//

import NormleLibrary
import StoreKitWrapper
import SwiftData
import SwiftUI

@main
struct NormleApp: App {
    @AppStorage(.isICloudOn)
    private var isICloudOn

    private var sharedModelContainer: ModelContainer!
    private var sharedStore: Store

    init() {
        sharedStore = .init()
        sharedModelContainer = {
            do {
                return try .init(
                    for: MaskRecord.self,
                    MaskRule.self,
                    Tag.self,
                    configurations: .init(
                        cloudKitDatabase: isICloudOn ? .automatic : .none
                    )
                )
            } catch {
                assertionFailure(error.localizedDescription)
                return try! .init(
                    for: MaskRecord.self,
                    MaskRule.self,
                    Tag.self,
                    configurations: .init(
                        isStoredInMemoryOnly: true
                    )
                )
            }
        }()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .id(isICloudOn)
                .modelContainer(sharedModelContainer)
                .environment(sharedStore)
        }
    }
}
