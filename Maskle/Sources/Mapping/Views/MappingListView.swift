//
//  MappingListView.swift
//
//
//  Created by Hiromu Nakano on 2025/11/23.
//

import MaskleLibrary
import SwiftData
import SwiftUI

struct MappingListView: View {
    @Environment(\.modelContext)
    private var context

    @Query private var rules: [ManualRule]
    @State private var isPresentingCreate = false

    init() {
        _rules = Query(
            FetchDescriptor(
                sortBy: [
                    .init(\ManualRule.createdAt, order: .reverse)
                ]
            )
        )
    }

    var body: some View {
        List {
            ForEach(rules) { rule in
                NavigationLink(value: rule) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(rule.alias.isEmpty ? "Alias not set" : rule.alias)
                            .font(.headline)
                        if rule.isEnabled == false {
                            Text("Disabled")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Text(rule.original.isEmpty ? "Original not set" : rule.original)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        HStack {
                            Text(rule.kind?.displayName ?? "Unknown")
                            Spacer()
                            Text(rule.createdAt.formatted(date: .abbreviated, time: .shortened))
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Mappings")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    isPresentingCreate = true
                } label: {
                    Label("Add", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $isPresentingCreate) {
            NavigationStack {
                MappingEditView(
                    rule: nil,
                    isPresented: $isPresentingCreate
                )
            }
        }
    }
}
