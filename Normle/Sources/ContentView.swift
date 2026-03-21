//
//  ContentView.swift
//  Normle
//
//  Created by Hiromu Nakano on 2025/11/23.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import MHPlatform
import NormleLibrary
import Observation
import SwiftUI

struct ContentView: View {
    @Environment(MHAppRuntime.self)
    private var runtime
    @Environment(NormleAppSessionController.self)
    private var sessionController
    @Environment(NormlePlatformEnvironment.self)
    private var platformEnvironment
    @Environment(\.modelContext)
    private var modelContext

    @AppStorage(BoolAppStorageKey.isSubscribeOn)
    private var isSubscribeOn
    @AppStorage(BoolAppStorageKey.isICloudOn)
    private var isICloudOn
    @State private var navigationModel = NormleNavigationModel()
    @State private var alertTitle = String()
    @State private var alertMessage = String()
    @State private var isShowingAlert = false

    @ViewBuilder var body: some View {
        tabContent
            .mhRouteHandler(platformEnvironment.routeInbox) { route in
                await navigationModel.apply(
                    route,
                    context: modelContext
                )
            }
    }

    private var tabContent: some View {
        @Bindable var navigationModel = navigationModel

        return TabView(selection: $navigationModel.selectedTab) {
            TransformNavigationView()
                .tabItem {
                    Label("Transforms", systemImage: "arrow.triangle.2.circlepath")
                }
                .tag(NormleRootTab.transforms)

            MappingNavigationView(
                path: $navigationModel.mappingPath
            )
            .tabItem {
                Label("Mappings", systemImage: "list.bullet.clipboard")
            }
            .tag(NormleRootTab.mappings)

            HistoryNavigationView(
                path: $navigationModel.historyPath
            )
            .tabItem {
                Label("History", systemImage: "clock.arrow.circlepath")
            }
            .tag(NormleRootTab.history)

            SettingsNavigationView(
                path: $navigationModel.settingsPath
            )
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
            .tag(NormleRootTab.settings)
        }
        .tabViewStyle(.automatic)
        .environment(navigationModel)
        .liquidGlassButtonStyle()
        .task(id: runtime.premiumStatus) {
            synchronizeSubscriptionAccess()
        }
        .task(id: sessionController.pendingAlert?.id) {
            presentPendingAlertIfNeeded()
        }
        .alert(
            alertTitle,
            isPresented: $isShowingAlert
        ) {
            Button("OK", role: .cancel) {
                isShowingAlert = false
            }
        } message: {
            Text(alertMessage)
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

    private func presentPendingAlertIfNeeded() {
        guard let pendingAlert = sessionController.consumePendingAlert() else {
            return
        }

        alertTitle = pendingAlert.title
        alertMessage = pendingAlert.message
        isShowingAlert = true
    }
}

#Preview("Content - Base") {
    let container = PreviewData.makeContainer()
    PreviewData.seed(container: container)
    let assembly = NormleAppAssembly.preview(container: container)
    return assembly.previewRootView(ContentView())
}
