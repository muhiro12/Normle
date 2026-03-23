//
//  SettingsListView.swift
//  Normle
//
//  Created by Hiromu Nakano on 2025/11/23.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import MHPlatform
import MHUI
import NormleLibrary
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

    @State private var screenModel = SettingsScreenModel()
    @State private var isDeleteDialogPresented = false
    @State private var isFactoryResetDialogPresented = false

    var body: some View {
        List {
            subscriptionSection
            dataSection
            helpSection
        }
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
                "This removes local history, mappings, tags, preferences, "
                    + "pending deep links, sync settings, and resets tips on the next launch."
            )
        }
        .alert(
            screenModel.alertTitle,
            isPresented: Binding(
                get: {
                    screenModel.isShowingAlert
                },
                set: { isPresented in
                    if isPresented == false {
                        screenModel.dismissAlert()
                    }
                }
            )
        ) {
            Button("OK", role: .cancel) {
                screenModel.dismissAlert()
            }
        } message: {
            Text(screenModel.alertMessage)
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
                .disabled(screenModel.factoryResetCoordinator.isRunning)
                .buttonStyle(.mhDestructive)

                Button(role: .destructive) {
                    isFactoryResetDialogPresented = true
                } label: {
                    Text("Factory reset app")
                }
                .disabled(screenModel.factoryResetCoordinator.isRunning)
                .buttonStyle(.mhDestructive)
            }

            if screenModel.factoryResetCoordinator.isRunning {
                ProgressView(
                    screenModel.factoryResetCoordinator.activeStepDescription ?? "Factory reset in progress"
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
                screenModel.resetTips()
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
            await screenModel.deleteAllHistory(
                context: context
            )
        }
    }

    func runFactoryReset() {
        Task {
            await screenModel.runFactoryReset(
                context: context,
                preferencesStore: platformEnvironment.preferencesStore,
                pendingRouteStore: platformEnvironment.pendingRouteStore,
                sessionController: sessionController
            )
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
