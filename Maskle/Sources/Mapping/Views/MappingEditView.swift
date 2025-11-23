//
//  MappingEditView.swift
//
//
//  Created by Hiromu Nakano on 2025/11/23.
//

import MaskleLibrary
import SwiftData
import SwiftUI

struct MappingEditView: View {
    @Environment(\.modelContext)
    private var context
    @Environment(\.dismiss)
    private var dismiss

    let rule: ManualRule?

    @Binding var isPresented: Bool

    @State private var original = String()
    @State private var alias = String()
    @State private var kind = MappingKind.custom
    @State private var isEnabled = true

    init(
        rule: ManualRule?,
        isPresented: Binding<Bool>,
        prefilledOriginal: String = String(),
        prefilledAlias: String = String(),
        prefilledKind: MappingKind = .custom,
        prefilledIsEnabled: Bool = true
    ) {
        self.rule = rule
        _isPresented = isPresented
        _original = .init(initialValue: prefilledOriginal)
        _alias = .init(initialValue: prefilledAlias)
        _kind = .init(initialValue: prefilledKind)
        _isEnabled = .init(initialValue: prefilledIsEnabled)
    }

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
            Section("Status") {
                Toggle("Enabled", isOn: $isEnabled)
            }
            Section {
                Button(saveTitle) {
                    save()
                }
                .disabled(original.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                            alias.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                if rule != nil {
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
        rule == nil ? "New Mapping" : "Edit Mapping"
    }

    var saveTitle: String {
        rule == nil ? "Create" : "Save"
    }

    func load() {
        guard let rule else {
            return
        }
        original = rule.original
        alias = rule.alias
        kind = rule.kind ?? .custom
        isEnabled = rule.isEnabled
    }

    func save() {
        let trimmedOriginal = original.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedAlias = alias.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedOriginal.isEmpty == false, trimmedAlias.isEmpty == false else {
            return
        }
        if let rule {
            rule.update(
                original: trimmedOriginal,
                alias: trimmedAlias,
                kind: kind,
                isEnabled: isEnabled
            )
        } else {
            ManualRule.create(
                context: context,
                original: trimmedOriginal,
                alias: trimmedAlias,
                kind: kind,
                isEnabled: isEnabled
            )
        }
        isPresented = false
        dismiss()
    }

    func delete() {
        guard let rule else {
            return
        }
        context.delete(rule)
        isPresented = false
        dismiss()
    }
}
