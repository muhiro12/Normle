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

    @State private var draft = MappingRuleDraft()
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
        _draft = .init(
            initialValue: .init(
                sourceText: prefilledSource,
                targetText: prefilledTarget,
                isEnabled: prefilledIsEnabled
            )
        )
    }

    var body: some View {
        Form {
            Section("Source") {
                TextField("Source text", text: $draft.sourceText)
            }
            Section("Target") {
                TextField("Target text", text: $draft.targetText)
            }
            Section("Status") {
                Toggle("Enabled", isOn: $draft.isEnabled)
            }
            Section {
                Button(saveTitle) {
                    save()
                }
                .disabled(draft.canSave == false)
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
            alertMessage ?? String(localized: "Error"),
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
        rule == nil ? String(localized: "New Mapping") : String(localized: "Edit Mapping")
    }

    var saveTitle: String {
        rule == nil ? String(localized: "Create") : String(localized: "Save")
    }

    func load() {
        guard let rule else {
            return
        }
        draft = .init(rule: rule)
    }

    func save() {
        do {
            _ = try draft.apply(
                context: context,
                to: rule
            )
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

#Preview("Mapping - New") {
    let container = PreviewData.makeContainer()
    return NavigationStack {
        MappingEditView(
            rule: nil,
            isPresented: .constant(true)
        )
    }
    .modelContainer(container)
}

#Preview("Mapping - Edit") {
    let container = PreviewData.makeContainer()
    let rule = PreviewData.makeSampleMappingRule(container: container)
    return NavigationStack {
        MappingEditView(
            rule: rule,
            isPresented: .constant(true)
        )
    }
    .modelContainer(container)
}
