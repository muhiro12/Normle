//
//  MappingDetailView.swift
//
//
//  Created by Hiromu Nakano on 2025/11/23.
//

import NormleLibrary
import SwiftUI

struct MappingDetailView: View {
    let rule: MaskRule

    @State private var isEditing = false

    var body: some View {
        List {
            Section("Masked") {
                Text(rule.masked.isEmpty ? "Not set" : rule.masked)
            }
            Section("Original") {
                Text(rule.original.isEmpty ? "Not set" : rule.original)
            }
            Section("Kind") {
                Text("Tags are not set")
            }
            Section("Status") {
                Text(rule.isEnabled ? "Enabled" : "Disabled")
            }
            Section("Created at") {
                Text(rule.date.formatted(date: .abbreviated, time: .shortened))
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
