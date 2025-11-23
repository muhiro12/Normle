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

    @State private var controller = MaskingController()
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
        @Bindable var controller = controller

        GeometryReader { proxy in
            ScrollView {
                VStack(spacing: 16) {
                    SectionContainer(title: "Original text") {
                        TextEditor(text: $controller.sourceText)
                            .frame(
                                minHeight: 180,
                                maxHeight: max(220, proxy.size.height * 0.6)
                            )
                    }

                    if let result = controller.result {
                        SectionContainer(title: "Masked text") {
                            TextEditor(text: .constant(result.maskedText))
                                .frame(
                                    minHeight: 180,
                                    maxHeight: max(220, proxy.size.height * 0.6)
                                )
                                .textSelection(.enabled)
                            CopyButton(text: result.maskedText)
                        }
                    } else {
                        SectionContainer(title: "Masked text") {
                            Text("Enter text above to see masked output.")
                                .foregroundStyle(.secondary)
                        }
                    }

                    if controller.result != nil {
                        SectionContainer {
                            Button {
                                controller.anonymize(
                                    context: context,
                                    options: maskingOptions(),
                                    manualRules: activeManualRules(),
                                    shouldSaveHistory: true,
                                    isHistoryAutoSaveEnabled: settingsStore.isHistoryAutoSaveEnabled
                                )
                            } label: {
                                Label("Save to history", systemImage: "tray.and.arrow.down")
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
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
        .onChange(of: controller.sourceText) { _, _ in
            anonymizeLive()
        }
        .onChange(of: manualRules) { _, _ in
            anonymizeLive()
        }
        .onChange(of: disabledRuleIDs) { _, _ in
            anonymizeLive()
        }
        .task {
            controller.loadLatestSavedSession(context: context)
        }
    }
}

private extension MaskView {
    struct SectionContainer<Content: View>: View {
        let title: String?
        @ViewBuilder let content: Content

        init(
            title: String? = nil,
            @ViewBuilder content: () -> Content
        ) {
            self.title = title
            self.content = content()
        }

        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                if let title {
                    Text(title)
                        .font(.headline)
                }
                VStack(alignment: .leading, spacing: 8) {
                    content
                }
                .padding(12)
                .background(.background)
                .clipShape(.rect(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(.quaternary, lineWidth: 1)
                )
            }
        }
    }

    func activeManualRules() -> [MaskingRule] {
        manualRules
            .filter { rule in
                rule.isEnabled && disabledRuleIDs.contains(rule.uuid) == false
            }
            .map(\.maskingRule)
    }

    func anonymizeLive() {
        guard controller.sourceText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
            controller.result = nil
            return
        }
        controller.anonymize(
            context: context,
            options: maskingOptions(),
            manualRules: activeManualRules(),
            shouldSaveHistory: false,
            isHistoryAutoSaveEnabled: settingsStore.isHistoryAutoSaveEnabled
        )
        controller.scheduleAutoSave(
            context: context,
            isHistoryAutoSaveEnabled: settingsStore.isHistoryAutoSaveEnabled
        )
    }

    func toggleDisabled(rule: ManualRule) {
        if disabledRuleIDs.contains(rule.uuid) {
            disabledRuleIDs.remove(rule.uuid)
        } else {
            disabledRuleIDs.insert(rule.uuid)
        }
    }

    func maskingOptions() -> MaskingOptions {
        .init(
            isURLMaskingEnabled: settingsStore.isURLMaskingEnabled,
            isEmailMaskingEnabled: settingsStore.isEmailMaskingEnabled,
            isPhoneMaskingEnabled: settingsStore.isPhoneMaskingEnabled
        )
    }
}
