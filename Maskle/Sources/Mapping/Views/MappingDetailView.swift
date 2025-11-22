//
//  MappingDetailView.swift
//
//
//  Created by Hiromu Nakano on 2025/11/23.
//

import MaskleLibrary
import SwiftUI

struct MappingDetailView: View {
    let rule: ManualRule

    @State private var isEditing = false

    var body: some View {
        List {
            Section("Alias") {
                Text(rule.alias.isEmpty ? "Not set" : rule.alias)
            }
            Section("Original") {
                Text(rule.original.isEmpty ? "Not set" : rule.original)
            }
            Section("Kind") {
                Text(rule.kind?.displayName ?? "Unknown")
            }
            Section("Status") {
                Text(rule.isEnabled ? "Enabled" : "Disabled")
            }
            Section("Created at") {
                Text(rule.createdAt.formatted(date: .abbreviated, time: .shortened))
            }
        }
        .navigationTitle("Mapping Detail")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") {
                    isEditing = true
                }
            }
        }
        .sheet(isPresented: $isEditing) {
            NavigationStack {
                MappingEditView(
                    rule: rule,
                    isPresented: $isEditing
                )
            }
        }
    }
}
