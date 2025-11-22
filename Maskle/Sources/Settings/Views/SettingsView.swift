//
//  SettingsView.swift
//
//
//  Created by Hiromu Nakano on 2025/11/23.
//

import MaskleLibrary
import SwiftData
import SwiftUI

struct SettingsView: View {
    @Environment(\.modelContext)
    private var context
    @Environment(SettingsStore.self)
    private var settingsStore

    @State private var isDeleteDialogPresented = false

    var body: some View {
        List {
            Section("Masking options") {
                Toggle("Mask URLs", isOn: binding(\.isURLMaskingEnabled))
                Toggle("Mask email addresses", isOn: binding(\.isEmailMaskingEnabled))
                Toggle("Mask phone numbers", isOn: binding(\.isPhoneMaskingEnabled))
            }

            Section("History") {
                Toggle("Auto save history", isOn: binding(\.isHistoryAutoSaveEnabled))
                Stepper(value: binding(\.historyLimit), in: 1...500) {
                    HStack {
                        Text("History limit")
                        Spacer()
                        Text("\(settingsStore.historyLimit) items")
                            .foregroundStyle(.secondary)
                    }
                }
                Button("Trim history to limit") {
                    do {
                        try SessionService.trimHistoryIfNeeded(
                            context: context,
                            limit: settingsStore.historyLimit
                        )
                    } catch {
                        assertionFailure(error.localizedDescription)
                    }
                }
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
                    try SessionService.deleteAll(context: context)
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
        .onChange(of: settingsStore.historyLimit) { _, newValue in
            do {
                try SessionService.trimHistoryIfNeeded(
                    context: context,
                    limit: newValue
                )
            } catch {
                assertionFailure(error.localizedDescription)
            }
        }
    }
}

private extension SettingsView {
    func binding<Value>(
        _ keyPath: ReferenceWritableKeyPath<SettingsStore, Value>
    ) -> Binding<Value> {
        .init(
            get: {
                settingsStore[keyPath: keyPath]
            },
            set: {
                settingsStore[keyPath: keyPath] = $0
            }
        )
    }
}
