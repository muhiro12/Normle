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

    let rule: MaskRule?

    @Binding var isPresented: Bool

    @State private var original = String()
    @State private var masked = String()
    @State private var isEnabled = true
    @State private var alertMessage: String?

    init(
        rule: MaskRule?,
        isPresented: Binding<Bool>,
        prefilledOriginal: String = String(),
        prefilledMasked: String = String(),
        prefilledIsEnabled: Bool = true
    ) {
        self.rule = rule
        _isPresented = isPresented
        _original = .init(initialValue: prefilledOriginal)
        _masked = .init(initialValue: prefilledMasked)
        _isEnabled = .init(initialValue: prefilledIsEnabled)
    }

    var body: some View {
        Form {
            Section("Original") {
                TextField("Original text", text: $original)
            }
            Section("Masked") {
                TextField("Masked text", text: $masked)
            }
            Section("Status") {
                Toggle("Enabled", isOn: $isEnabled)
            }
            Section {
                Button(saveTitle) {
                    save()
                }
                .disabled(original.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                            masked.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
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
        original = rule.original
        masked = rule.masked
        isEnabled = rule.isEnabled
    }

    func save() {
        let trimmedOriginal = original.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedMasked = masked.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedOriginal.isEmpty == false, trimmedMasked.isEmpty == false else {
            return
        }
        do {
            if let rule {
                try rule.update(
                    context: context,
                    original: trimmedOriginal,
                    masked: trimmedMasked,
                    isEnabled: isEnabled
                )
            } else {
                try MaskRule.create(
                    context: context,
                    original: trimmedOriginal,
                    masked: trimmedMasked,
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
