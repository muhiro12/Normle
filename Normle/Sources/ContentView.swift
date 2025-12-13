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

private enum SidebarItem: Hashable {
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
    @State private var selection: SidebarItem? = .mask

    var body: some View {
        NavigationSplitView {
            List(selection: $selection) {
                NavigationLink(value: SidebarItem.mask) {
                    Label("Mask", systemImage: "wand.and.stars")
                }
                NavigationLink(value: SidebarItem.mappings) {
                    Label("Mappings", systemImage: "list.bullet.clipboard")
                }
                NavigationLink(value: SidebarItem.history) {
                    Label("History", systemImage: "clock.arrow.circlepath")
                }
                NavigationLink(value: SidebarItem.settings) {
                    Label("Settings", systemImage: "gear")
                }
            }
            .navigationTitle("Normle")
        } detail: {
            switch selection {
            case .mask:
                NavigationStack {
                    MaskView()
                }
            case .mappings:
                MappingNavigationView()
            case .history:
                HistoryNavigationView()
            case .settings:
                SettingsNavigationView()
            case .none:
                NavigationStack {
                    MaskView()
                }
            }
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
