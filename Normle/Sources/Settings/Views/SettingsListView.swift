//
//  SettingsListView.swift
//  Normle
//
//  Created by Hiromu Nakano on 2025/11/23.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import NormleLibrary
import SwiftData
import SwiftUI

struct SettingsListView: View {
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
    }
}

private extension SettingsListView {
    func deleteAllHistory() {
        do {
            try TransformRecordService.deleteAll(
                context: context
            )
        } catch {
            assertionFailure(error.localizedDescription)
        }
    }
}

#Preview("Settings - Base") {
    let container = PreviewData.makeContainer()
    return NavigationStack {
        SettingsListView()
    }
    .modelContainer(container)
}
