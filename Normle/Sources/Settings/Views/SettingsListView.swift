//
//  SettingsListView.swift
//  Normle
//
//  Created by Hiromu Nakano on 2025/11/23.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import MHPreferences
import MHUI
import NormleLibrary
import Observation
import SwiftData
import SwiftUI
import TipKit

struct SettingsListView: View {
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
        .mhListChrome(title: "Settings")
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
                        .mhRow()
                }
                .popoverTip(SubscriptionSyncTip())
            }
        } header: {
            Text("Subscription")
                .mhSectionHeaderTitle()
                .mhSectionHeader()
        } footer: {
            Text("Manage your subscription and sync preferences.")
                .mhSectionFooterText()
        }
    }

    var dataSection: some View {
        Section {
            MHActionGroup(layout: .automatic) {
                Button(role: .destructive) {
                    isDeleteDialogPresented = true
                } label: {
                    Text("Delete all history")
                }
                .disabled(factoryResetCoordinator.isRunning)
                .buttonStyle(.mhDestructive)

                Button(role: .destructive) {
                    isFactoryResetDialogPresented = true
                } label: {
                    Text("Factory reset app")
                }
                .disabled(factoryResetCoordinator.isRunning)
                .buttonStyle(.mhDestructive)
            }

            if factoryResetCoordinator.isRunning {
                ProgressView(
                    factoryResetCoordinator.activeStepDescription ?? "Factory reset in progress"
                )
                .frame(maxWidth: .infinity, alignment: .leading)
                .mhRow()
            }
        } header: {
            Text("Data")
                .mhSectionHeaderTitle()
                .mhSectionHeader()
        } footer: {
            Text("Factory reset removes all local data and settings on this device.")
                .mhSectionFooterText()
        }
    }

    var helpSection: some View {
        Section {
            Button("Show tips again") {
                resetTips()
            }
            .buttonStyle(.mhSecondary)
        } header: {
            Text("Help")
                .mhSectionHeaderTitle()
                .mhSectionHeader()
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
