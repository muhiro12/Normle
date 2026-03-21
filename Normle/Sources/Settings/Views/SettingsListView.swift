//
//  SettingsListView.swift
//  Normle
//
//  Created by Hiromu Nakano on 2025/11/23.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import MHPlatform
import NormleLibrary
import Observation
import SwiftData
import SwiftUI
import TipKit

struct SettingsListView: View {
    private enum Layout {
        static let listRowSpacing = 8.0
        static let horizontalPadding = 16.0
    }

    @Environment(\.modelContext)
    private var context
    @Environment(NormleAppSessionController.self)
    private var sessionController
    @Environment(NormlePlatformEnvironment.self)
    private var platformEnvironment
    @AppStorage(BoolAppStorageKey.isSubscribeOn)
    private var isSubscribeOn
    @AppStorage(BoolAppStorageKey.isICloudOn)
    private var isICloudOn

    @State private var isDeleteDialogPresented = false
    @State private var isFactoryResetDialogPresented = false
    @State private var alertTitle = String()
    @State private var alertMessage = String()
    @State private var isShowingAlert = false
    @State private var tipsRefreshID: UUID = .init()
    @State private var factoryResetCoordinator = NormleFactoryResetCoordinator()

    var body: some View {
        List {
            subscriptionSection
            dataSection
            helpSection
        }
        .id(tipsRefreshID)
        .navigationTitle("Settings")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        .listRowSpacing(Layout.listRowSpacing)
        #endif
        #if os(macOS)
        .listStyle(.inset)
        .padding(.horizontal, Layout.horizontalPadding)
        #else
        .listStyle(.insetGrouped)
        #endif
        .confirmationDialog(
            "Delete all history?",
            isPresented: $isDeleteDialogPresented
        ) {
            Button(role: .destructive) {
                deleteAllHistory()
            } label: {
                Text("Delete")
            }
            Button(role: .cancel) {
                isDeleteDialogPresented = false
            } label: {
                Text("Cancel")
            }
        }
        .confirmationDialog(
            "Factory reset app?",
            isPresented: $isFactoryResetDialogPresented
        ) {
            Button(role: .destructive) {
                runFactoryReset()
            } label: {
                Text("Factory Reset")
            }
            Button(role: .cancel) {
                isFactoryResetDialogPresented = false
            } label: {
                Text("Cancel")
            }
        } message: {
            Text(
                "This removes local history, mappings, tags, preferences, tips, "
                    + "pending deep links, and sync settings on this device."
            )
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
}

private extension SettingsListView {
    var subscriptionSection: some View {
        Section {
            if isSubscribeOn {
                Toggle("Use iCloud sync", isOn: $isICloudOn)
                    .popoverTip(isICloudOn ? nil : ICloudSyncTip())
            } else {
                NavigationLink(value: NormleSettingsDestination.subscription) {
                    Text("Subscription")
                }
                .popoverTip(SubscriptionSyncTip())
            }
        } header: {
            Text("Subscription")
        } footer: {
            Text("Manage your subscription and sync preferences.")
        }
    }

    var dataSection: some View {
        Section {
            Button(role: .destructive) {
                isDeleteDialogPresented = true
            } label: {
                Text("Delete all history")
            }
            .disabled(factoryResetCoordinator.isRunning)

            Button(role: .destructive) {
                isFactoryResetDialogPresented = true
            } label: {
                Text("Factory reset app")
            }
            .disabled(factoryResetCoordinator.isRunning)

            if factoryResetCoordinator.isRunning {
                ProgressView(
                    factoryResetCoordinator.activeStepDescription ?? "Factory reset in progress"
                )
            }
        } header: {
            Text("Data")
        } footer: {
            Text("Factory reset removes all local data and settings on this device.")
        }
    }

    var helpSection: some View {
        Section("Help") {
            Button("Show tips again") {
                resetTips()
            }
        }
    }

    func deleteAllHistory() {
        Task {
            await deleteAllHistoryTask()
        }
    }

    func runFactoryReset() {
        Task {
            await factoryResetCoordinator.run(
                context: context,
                preferencesStore: platformEnvironment.preferencesStore,
                pendingRouteStore: platformEnvironment.pendingRouteStore,
                sessionController: sessionController
            )
        }
    }

    func resetTips() {
        do {
            try NormleTipManager.reset()
            tipsRefreshID = .init()
            alertTitle = String(localized: "Tips reset")
            alertMessage = String(localized: "Tips will appear again as you move through the app.")
            isShowingAlert = true
        } catch {
            alertTitle = String(localized: "Error")
            alertMessage = error.localizedDescription
            isShowingAlert = true
        }
    }

    @MainActor
    func deleteAllHistoryTask() async {
        do {
            try await NormleMutationWorkflow.deleteAllHistory(
                context: context
            )
        } catch {
            assertionFailure(error.localizedDescription)
        }
    }
}

#Preview("Settings - Base") {
    let container = PreviewData.makeContainer()
    let assembly = NormleAppAssembly.preview(container: container)
    return assembly.previewRootView(
        SettingsNavigationView(
            path: .constant(.init())
        )
    )
}
