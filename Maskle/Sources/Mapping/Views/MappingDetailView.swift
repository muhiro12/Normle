//
//  MappingDetailView.swift
//
//
//  Created by Hiromu Nakano on 2025/11/23.
//

import MaskleLibrary
import SwiftUI

struct MappingDetailView: View {
    @Environment(MaskSessionStore.self)
    private var maskSessionStore

    let ruleID: UUID

    @State private var isEditing = false

    var body: some View {
        if let rule = maskSessionStore.rule(id: ruleID) {
            List {
                Section("Alias") {
                    Text(rule.alias.isEmpty ? "Not set" : rule.alias)
                }
                Section("Original") {
                    Text(rule.original.isEmpty ? "Not set" : rule.original)
                }
                Section("Kind") {
                    Text(rule.kind.displayName)
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
                        ruleID: rule.id,
                        isPresented: $isEditing
                    )
                }
            }
        } else {
            Text("Mapping not found")
                .foregroundStyle(.secondary)
        }
    }
}
