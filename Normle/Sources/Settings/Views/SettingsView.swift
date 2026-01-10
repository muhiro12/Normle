//
//  SettingsView.swift
//
//
//  Created by Hiromu Nakano on 2025/11/23.
//

import NormleLibrary
import SwiftData
import SwiftUI

struct SettingsView: View {
    @Environment(\.modelContext)
    private var context
    @AppStorage(.isSubscribeOn)
    private var isSubscribeOn
    @AppStorage(.isICloudOn)
    private var isICloudOn
    @AppStorage(.isHistoryAutoSaveEnabled)
    private var isHistoryAutoSaveEnabled = true

    @State private var isDeleteDialogPresented = false

    var body: some View {
        List {
            Section("Subscription") {
                if isSubscribeOn {
                    Toggle("Use iCloud sync", isOn: $isICloudOn)
                } else {
                    NavigationLink {
                        StoreNavigationView()
                    } label: {
                        Text("Subscription")
                    }
                }
            }
            Section("History") {
                Toggle("Auto save history", isOn: $isHistoryAutoSaveEnabled)
            }

            Section {
                Button(role: .destructive) {
                    isDeleteDialogPresented = true
                } label: {
                    Text("Delete all history")
                }
            }
        }
        .navigationTitle("Settings")
        .confirmationDialog(
            "Delete all history?",
            isPresented: $isDeleteDialogPresented
        ) {
            Button(role: .destructive) {
                do {
                    try TransformRecordService.deleteAll(context: context)
                } catch {
                    assertionFailure(error.localizedDescription)
                }
            } label: {
                Text("Delete")
            }
            Button(role: .cancel) {
            } label: {
                Text("Cancel")
            }
        }
    }
}
