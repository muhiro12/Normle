//
//  MappingEditView.swift
//
//
//  Created by Hiromu Nakano on 2025/11/23.
//

import MaskleLibrary
import SwiftUI

struct MappingEditView: View {
    @Environment(MaskSessionStore.self)
    private var maskSessionStore
    @Environment(\.dismiss)
    private var dismiss

    let ruleID: UUID?

    @Binding var isPresented: Bool

    @State private var original = String()
    @State private var alias = String()
    @State private var kind = MappingKind.custom

    var body: some View {
        Form {
            Section("Original") {
                TextField("Original text", text: $original)
            }
            Section("Alias") {
                TextField("Alias", text: $alias)
            }
            Section("Kind") {
                Picker("Kind", selection: $kind) {
                    ForEach(MappingKind.allCases) { value in
                        Text(value.displayName).tag(value)
                    }
                }
            }
            Section {
                Button(saveTitle) {
                    save()
                }
                .disabled(original.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                            alias.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                if ruleID != nil {
                    Button("Delete", role: .destructive) {
                        delete()
                    }
                }
            }
        }
        .navigationTitle(title)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    isPresented = false
                    dismiss()
                }
            }
        }
        .onAppear {
            load()
        }
    }
}

private extension MappingEditView {
    var title: String {
        ruleID == nil ? "New Mapping" : "Edit Mapping"
    }

    var saveTitle: String {
        ruleID == nil ? "Create" : "Save"
    }

    func load() {
        guard let ruleID,
              let rule = maskSessionStore.rule(id: ruleID) else {
            return
        }
        original = rule.original
        alias = rule.alias
        kind = rule.kind
    }

    func save() {
        let trimmedOriginal = original.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedAlias = alias.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedOriginal.isEmpty == false, trimmedAlias.isEmpty == false else {
            return
        }
        if let ruleID {
            maskSessionStore.updateRule(
                id: ruleID,
                original: trimmedOriginal,
                alias: trimmedAlias,
                kind: kind
            )
        } else {
            _ = maskSessionStore.addRule(
                original: trimmedOriginal,
                alias: trimmedAlias,
                kind: kind
            )
        }
        isPresented = false
        dismiss()
    }

    func delete() {
        guard let ruleID else {
            return
        }
        maskSessionStore.removeRule(id: ruleID)
        isPresented = false
        dismiss()
    }
}
