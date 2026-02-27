//
//  ContentView.swift
//
//
//  Created by Hiromu Nakano on 2025/11/23.
//

import NormleLibrary
import StoreKitWrapper
import SwiftData
import SwiftUI

private enum Tab: Hashable {
    case transforms
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
        .task {
            #if os(macOS)
            let accessState = SubscriptionAccessEvaluator.evaluate(
                hasActiveSubscription: false,
                isICloudOn: isICloudOn,
                grantsPremiumAccessWithoutSubscription: true
            )
            isSubscribeOn = accessState.isSubscribeOn
            isICloudOn = accessState.isICloudOn
            #else
            store.open(
                groupID: nil,
                productIDs: [Secret.productID]
            ) {
                let accessState = SubscriptionAccessEvaluator.evaluate(
                    purchasedProductIDs: Set($0.map(\.id)),
                    productID: Secret.productID,
                    isICloudOn: isICloudOn
                )
                isSubscribeOn = accessState.isSubscribeOn
                isICloudOn = accessState.isICloudOn
            }
            #endif
        }
    }
}

#Preview("Content - Base") {
    let container = PreviewData.makeContainer()
    PreviewData.seed(container: container)
    let preferencesStore = UserPreferencesStore()
    let store = Store()
    return ContentView()
        .modelContainer(container)
        .environment(store)
        .environmentObject(preferencesStore)
}
