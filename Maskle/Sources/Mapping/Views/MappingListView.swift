//
//  MappingListView.swift
//
//
//  Created by Hiromu Nakano on 2025/11/23.
//

import MaskleLibrary
import SwiftUI

struct MappingListView: View {
    @Environment(MaskSessionStore.self)
    private var maskSessionStore

    @State private var path = NavigationPath()
    @State private var isPresentingCreate = false

    var body: some View {
        List {
            ForEach(maskSessionStore.sortedRules) { rule in
                NavigationLink(value: rule.id) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(rule.alias.isEmpty ? "Alias not set" : rule.alias)
                            .font(.headline)
                        Text(rule.original.isEmpty ? "Original not set" : rule.original)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        HStack {
                            Text(rule.kind.displayName)
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
        .navigationDestination(for: UUID.self) { id in
            MappingDetailView(ruleID: id)
        }
        .sheet(isPresented: $isPresentingCreate) {
            NavigationStack {
                MappingEditView(
                    ruleID: nil,
                    isPresented: $isPresentingCreate
                )
            }
        }
    }
}
