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

    @State private var isDeleteDialogPresented = false

    var body: some View {
        List {
            Section {
                if isSubscribeOn {
                    Toggle("Use iCloud sync", isOn: $isICloudOn)
                } else {
                    NavigationLink {
                        StoreNavigationView()
                    } label: {
                        Text("Subscription")
                    }
                }
            } header: {
                Text("Subscription")
            } footer: {
                Text("Manage your subscription and sync preferences.")
            }
            Section {
                Button(role: .destructive) {
                    isDeleteDialogPresented = true
                } label: {
                    Text("Delete all history")
                }
            } header: {
                Text("Data")
            } footer: {
                Text("This action cannot be undone.")
            }
        }
        .navigationTitle("Settings")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        .listRowSpacing(8)
        #endif
        #if os(macOS)
        .listStyle(.inset)
        .padding(.horizontal, 16)
        #else
        .listStyle(.insetGrouped)
        #endif
        .confirmationDialog(
            "Delete all history?",
            isPresented: $isDeleteDialogPresented
        ) {
            Button(role: .destructive) {
                HistoryDeletionService.deleteAll(context: context)
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

#Preview("Settings - Base") {
    let container = PreviewData.makeContainer()
    return NavigationStack {
        SettingsView()
    }
    .modelContainer(container)
}
