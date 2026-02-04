//
//  MappingDetailView.swift
//
//
//  Created by Hiromu Nakano on 2025/11/23.
//

import NormleLibrary
import SwiftData
import SwiftUI

struct MappingDetailView: View {
    let rule: MappingRule

    @State private var isEditing = false

    var body: some View {
        List {
            Section("Target") {
                Text(rule.target.isEmpty ? String(localized: "Not set") : rule.target)
            }
            Section("Source") {
                Text(rule.source.isEmpty ? String(localized: "Not set") : rule.source)
            }
            Section("Kind") {
                Text("Tags are not set")
            }
            Section("Status") {
                Text(rule.isEnabled ? String(localized: "Enabled") : String(localized: "Disabled"))
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

#Preview("Mapping - Detail") {
    let container = PreviewData.makeContainer()
    let rule = PreviewData.makeSampleMappingRule(container: container)
    return NavigationStack {
        MappingDetailView(rule: rule)
    }
    .modelContainer(container)
}
