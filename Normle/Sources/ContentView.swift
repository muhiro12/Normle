//
//  ContentView.swift
//
//
//  Created by Hiromu Nakano on 2025/11/23.
//

import NormleLibrary
import StoreKit
import StoreKitWrapper
import SwiftUI

private enum Tab: Hashable {
    case mask
    case mappings
    case history
    case settings
}

struct ContentView: View {
    @Environment(Store.self)
    private var store

    @AppStorage(.isSubscribeOn)
    private var isSubscribeOn
    @AppStorage(.isICloudOn)
    private var isICloudOn
    @State private var selection: Tab = .mask

    var body: some View {
        TabView(selection: $selection) {
            NavigationStack {
                MaskView()
            }
            .tabItem {
                Label("Mask", systemImage: "wand.and.stars")
            }
            .tag(Tab.mask)

            MappingNavigationView()
                .tabItem {
                    Label("Mappings", systemImage: "list.bullet.clipboard")
                }
                .tag(Tab.mappings)

            HistoryNavigationView()
                .tabItem {
                    Label("History", systemImage: "clock.arrow.circlepath")
                }
                .tag(Tab.history)

            SettingsNavigationView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(Tab.settings)
        }
        .task {
            store.open(
                groupID: nil,
                productIDs: [StoreProduct.subscription]
            ) {
                isSubscribeOn = $0.contains {
                    $0.id == StoreProduct.subscription
                }
                if !isSubscribeOn {
                    isICloudOn = false
                }
            }
        }
    }
}
