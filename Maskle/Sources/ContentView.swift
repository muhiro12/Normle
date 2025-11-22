//
//  ContentView.swift
//
//
//  Created by Hiromu Nakano on 2025/11/23.
//

import SwiftUI

private enum SidebarItem: Hashable {
    case mask
    case mappings
    case history
    case settings
}

struct ContentView: View {
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
            .navigationTitle("Maskle")
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
    }
}
