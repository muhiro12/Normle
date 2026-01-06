//
//  MaskView.swift
//
//
//  Created by Hiromu Nakano on 2025/11/23.
//

import NormleLibrary
#if os(macOS)
import AppKit
#endif
import SwiftData
import SwiftUI

struct MaskView: View {
    @Environment(\.modelContext)
    private var context
    @AppStorage(.isURLMaskingEnabled)
    private var isURLMaskingEnabled = true
    @AppStorage(.isEmailMaskingEnabled)
    private var isEmailMaskingEnabled = true
    @AppStorage(.isPhoneMaskingEnabled)
    private var isPhoneMaskingEnabled = true
    @AppStorage(.isHistoryAutoSaveEnabled)
    private var isHistoryAutoSaveEnabled = true

    @Query private var mappingRules: [MappingRule]

    @State private var controller = MaskingController()
    @State private var disabledRuleIDs = Set<PersistentIdentifier>()
    @State private var selectedSourceTextRaw = String()
    @State private var isPresentingMappingCreation = false
    @State private var pendingSourceForMapping = String()

    init() {
        _mappingRules = Query(
            FetchDescriptor(
                sortBy: [
                    .init(\MappingRule.date, order: .reverse)
                ]
            )
        )
    }

    var body: some View {
        @Bindable var controller = controller

        Form {
            Section("Source text") {
                TextEditor(
                    text: $controller.sourceText
                )
                .frame(minHeight: 180)
                Button {
                    pasteSourceText()
                } label: {
                    Label("Paste", systemImage: "doc.on.clipboard")
                }
                Button {
                    clearSourceText()
                } label: {
                    Label("Clear", systemImage: "xmark.circle")
                }
                Button {
                    presentMappingFromSelection()
                } label: {
                    Label("Create mapping from selection", systemImage: "plus")
                }
                .disabled(selectedSourceText == nil)
            }

            Section("Target text") {
                if let result = controller.result {
                    TextEditor(text: .constant(result.maskedText))
                        .frame(minHeight: 180)
                        .textSelection(.enabled)
                    CopyButton(text: result.maskedText)
                } else {
                    Text("Enter text above to see masked output.")
                        .foregroundStyle(.secondary)
                }
            }

            if controller.result != nil {
                Section {
                    Button {
                        controller.anonymize(
                            context: context,
                            options: maskingOptions(),
                            maskRules: activeMaskRules(),
                            shouldSaveHistory: true,
                            isHistoryAutoSaveEnabled: isHistoryAutoSaveEnabled
                        )
                    } label: {
                        Label("Save to history", systemImage: "tray.and.arrow.down")
                    }
                }
            }
        }
        .navigationTitle("Custom")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    if mappingRules.isEmpty {
                        Text("No manual mappings")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(mappingRules) { rule in
                            Button {
                                toggleDisabled(rule: rule)
                            } label: {
                                HStack {
                                    Text(rule.target.isEmpty ? String(localized: "Target not set") : rule.target)
                                    Spacer()
                                    if disabledRuleIDs.contains(rule.persistentModelID) {
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
        .onChange(of: mappingRules) { _, _ in
            anonymizeLive()
        }
        .onChange(of: disabledRuleIDs) { _, _ in
            anonymizeLive()
        }
        #if os(macOS)
        .onReceive(
            NotificationCenter.default.publisher(
                for: NSTextView.didChangeSelectionNotification
            )
        ) { notification in
            updateSelectedSourceText(notification: notification)
        }
        #endif
        .task {
            controller.loadLatestSavedRecord(context: context)
        }
        .sheet(isPresented: $isPresentingMappingCreation) {
            NavigationStack {
                MappingEditView(
                    rule: nil,
                    isPresented: $isPresentingMappingCreation,
                    prefilledSource: pendingSourceForMapping
                )
            }
        }
    }
}

private extension MaskView {
    func activeMaskRules() -> [MaskingRule] {
        mappingRules
            .filter { rule in
                rule.isEnabled && disabledRuleIDs.contains(rule.persistentModelID) == false
            }
            .map(\.maskingRule)
    }

    var selectedSourceText: String? {
        let trimmed = selectedSourceTextRaw.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
    func anonymizeLive() {
        guard controller.sourceText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
            controller.result = nil
            return
        }
        controller.anonymize(
            context: context,
            options: maskingOptions(),
            maskRules: activeMaskRules(),
            shouldSaveHistory: false,
            isHistoryAutoSaveEnabled: isHistoryAutoSaveEnabled
        )
        controller.scheduleAutoSave(
            context: context,
            isHistoryAutoSaveEnabled: isHistoryAutoSaveEnabled
        )
    }

    func presentMappingFromSelection() {
        guard let selectedSourceText else {
            return
        }
        pendingSourceForMapping = selectedSourceText
        isPresentingMappingCreation = true
    }

    func toggleDisabled(rule: MappingRule) {
        if disabledRuleIDs.contains(rule.persistentModelID) {
            disabledRuleIDs.remove(rule.persistentModelID)
        } else {
            disabledRuleIDs.insert(rule.persistentModelID)
        }
    }

    func maskingOptions() -> MaskingOptions {
        .init(
            isURLMaskingEnabled: isURLMaskingEnabled,
            isEmailMaskingEnabled: isEmailMaskingEnabled,
            isPhoneMaskingEnabled: isPhoneMaskingEnabled
        )
    }

    func pasteSourceText() {
        guard let pastedText = ClipboardService.pasteText() else {
            return
        }
        controller.sourceText = pastedText
    }

    func clearSourceText() {
        controller.sourceText = String()
    }
}

#if os(macOS)
private extension MaskView {
    func updateSelectedSourceText(notification: Notification) {
        guard let textView = notification.object as? NSTextView else {
            return
        }

        guard textView.window?.isKeyWindow == true else {
            return
        }

        guard textView.string == controller.sourceText else {
            return
        }

        let selection = textView.selectedRange()

        guard selection.length > 0,
              let range = Range(selection, in: controller.sourceText) else {
            selectedSourceTextRaw = String()
            return
        }

        let trimmed = controller.sourceText[range]
            .trimmingCharacters(in: .whitespacesAndNewlines)

        selectedSourceTextRaw = String(trimmed)
    }
}
#else
private extension MaskView {
    func updateSelectedSourceText(notification _: Notification) {}
}
#endif
