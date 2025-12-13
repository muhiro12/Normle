//
//  MappingEditView.swift
//
//
//  Created by Hiromu Nakano on 2025/11/23.
//

import NormleLibrary
import SwiftData
import SwiftUI

struct MappingEditView: View {
    @Environment(\.modelContext)
    private var context
    @Environment(\.dismiss)
    private var dismiss

    let rule: MappingRule?

    @Binding var isPresented: Bool

    @State private var source = String()
    @State private var target = String()
    @State private var isEnabled = true
    @State private var alertMessage: String?

    init(
        rule: MappingRule?,
        isPresented: Binding<Bool>,
        prefilledSource: String = String(),
        prefilledTarget: String = String(),
        prefilledIsEnabled: Bool = true
    ) {
        self.rule = rule
        _isPresented = isPresented
        _source = .init(initialValue: prefilledSource)
        _target = .init(initialValue: prefilledTarget)
        _isEnabled = .init(initialValue: prefilledIsEnabled)
    }

    var body: some View {
        Form {
            Section("Source") {
                TextField("Source text", text: $source)
            }
            Section("Target") {
                TextField("Target text", text: $target)
            }
            Section("Status") {
                Toggle("Enabled", isOn: $isEnabled)
            }
            Section {
                Button(saveTitle) {
                    save()
                }
                .disabled(source.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                            target.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
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
        .alert(
            alertMessage ?? "Error",
            isPresented: .init(
                get: { alertMessage != nil },
                set: { isPresented in
                    if isPresented == false {
                        alertMessage = nil
                    }
                }
            )
        ) {
            Button("OK", role: .cancel) {
            }
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
        source = rule.source
        target = rule.target
        isEnabled = rule.isEnabled
    }

    func save() {
        let trimmedSource = source.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedTarget = target.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedSource.isEmpty == false, trimmedTarget.isEmpty == false else {
            return
        }
        do {
            if let rule {
                try rule.update(
                    context: context,
                    source: trimmedSource,
                    target: trimmedTarget,
                    isEnabled: isEnabled
                )
            } else {
                try MappingRule.create(
                    context: context,
                    source: trimmedSource,
                    target: trimmedTarget,
                    isEnabled: isEnabled
                )
            }
        } catch {
            alertMessage = error.localizedDescription
            return
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
