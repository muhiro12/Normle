//
//  ContentView.swift
//  Normle
//
//  Created by Hiromu Nakano on 2025/11/23.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import MHPlatform
import NormleLibrary
import SwiftUI

struct ContentView: View {
    private enum Tab: Hashable {
        case transforms
        case mappings
        case history
        case settings
    }

    @Environment(MHAppRuntime.self)
    private var runtime

    @AppStorage(.isSubscribeOn)
    private var isSubscribeOn
    @AppStorage(.isICloudOn)
    private var isICloudOn
    @State private var selection: Tab = .transforms

    var body: some View {
        TabView(selection: $selection) {
            NavigationStack {
                TransformsHomeView()
            }
            .tabItem {
                Label("Transforms", systemImage: "arrow.triangle.2.circlepath")
            }
            .tag(Tab.transforms)

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
        .liquidGlassButtonStyle()
        .task(id: runtime.premiumStatus) {
            synchronizeSubscriptionAccess()
        }
    }

    private func synchronizeSubscriptionAccess() {
        #if os(macOS)
        applyAccessState(
            SubscriptionAccessEvaluator.evaluate(
                hasActiveSubscription: false,
                isICloudOn: isICloudOn,
                grantsPremiumAccessWithoutSubscription: true
            )
        )
        #else
        guard runtime.premiumStatus != .unknown else {
            return
        }

        applyAccessState(
            SubscriptionAccessEvaluator.evaluate(
                hasActiveSubscription: runtime.premiumStatus == .active,
                isICloudOn: isICloudOn
            )
        )
        #endif
    }

    private func applyAccessState(
        _ accessState: SubscriptionAccessState
    ) {
        isSubscribeOn = accessState.isSubscribeOn
        isICloudOn = accessState.isICloudOn
    }
}

#Preview("Content - Base") {
    let container = PreviewData.makeContainer()
    PreviewData.seed(container: container)
    let assembly = NormleAppAssembly.preview(container: container)
    return assembly.rootView(
        ContentView(),
        applyRuntimeBootstrap: false
    )
}
