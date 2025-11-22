//
//  MaskView.swift
//
//
//  Created by Hiromu Nakano on 2025/11/23.
//

import MaskleLibrary
import SwiftData
import SwiftUI

struct MaskView: View {
    @Environment(\.modelContext)
    private var context
    @Environment(SettingsStore.self)
    private var settingsStore

    @Query private var manualRules: [ManualRule]

    @State private var viewModel = MaskViewModel()
    @State private var disabledRuleIDs = Set<UUID>()

    init() {
        _manualRules = Query(
            FetchDescriptor(
                sortBy: [
                    .init(\ManualRule.createdAt, order: .reverse)
                ]
            )
        )
    }

    var body: some View {
        List {
            Section("Original text") {
                TextEditor(text: $viewModel.sourceText)
                    .frame(minHeight: 180)
            }

            if let result = viewModel.result {
                Section("Masked text") {
                    TextEditor(text: .constant(result.maskedText))
                        .frame(minHeight: 180)
                        .textSelection(.enabled)
                    CopyButton(text: result.maskedText)
                }
            } else {
                Section("Masked text") {
                    Text("Enter text above to see masked output.")
                        .foregroundStyle(.secondary)
                }
            }

            if viewModel.result != nil {
                Section {
                    Button {
                        viewModel.anonymize(
                            context: context,
                            settingsStore: settingsStore,
                            manualRules: activeManualRules(),
                            shouldSaveHistory: true
                        )
                    } label: {
                        Label("Save to history", systemImage: "tray.and.arrow.down")
                    }
                }
            }
        }
        .navigationTitle("Mask")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    if manualRules.isEmpty {
                        Text("No manual mappings")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(manualRules) { rule in
                            Button {
                                toggleDisabled(rule: rule)
                            } label: {
                                HStack {
                                    Text(rule.alias.isEmpty ? "Alias not set" : rule.alias)
                                    Spacer()
                                    if disabledRuleIDs.contains(rule.uuid) {
                                        Image(systemName: "slash.circle")
                                    } else {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    }
                } label: {
                    Label("Mappings", systemImage: "slider.horizontal.3")
                }
            }
        }
        .onChange(of: viewModel.sourceText) { _ in
            anonymizeLive()
        }
        .onChange(of: manualRules) { _ in
            anonymizeLive()
        }
        .onChange(of: disabledRuleIDs) { _ in
            anonymizeLive()
        }
    }
}

private extension MaskView {
    func activeManualRules() -> [MaskingRule] {
        manualRules
            .filter { rule in
                rule.isEnabled && disabledRuleIDs.contains(rule.uuid) == false
            }
            .map(\.maskingRule)
    }

    func anonymizeLive() {
        guard viewModel.sourceText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
            viewModel.result = nil
            return
        }
        viewModel.anonymize(
            context: context,
            settingsStore: settingsStore,
            manualRules: activeManualRules(),
            shouldSaveHistory: false
        )
    }

    func toggleDisabled(rule: ManualRule) {
        if disabledRuleIDs.contains(rule.uuid) {
            disabledRuleIDs.remove(rule.uuid)
        } else {
            disabledRuleIDs.insert(rule.uuid)
        }
    }
}
