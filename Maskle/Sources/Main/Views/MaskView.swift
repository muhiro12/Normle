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
    @AppStorage(.isURLMaskingEnabled)
    private var isURLMaskingEnabled = true
    @AppStorage(.isEmailMaskingEnabled)
    private var isEmailMaskingEnabled = true
    @AppStorage(.isPhoneMaskingEnabled)
    private var isPhoneMaskingEnabled = true
    @AppStorage(.isHistoryAutoSaveEnabled)
    private var isHistoryAutoSaveEnabled = true

    @Query private var manualRules: [ManualRule]

    @State private var controller = MaskingController()
    @State private var disabledRuleIDs = Set<UUID>()
    @State private var sourceSelection: TextSelection?
    @State private var isPresentingMappingCreation = false
    @State private var pendingOriginalForMapping = String()

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
                content(proxy: proxy, controller: controller)
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
        .sheet(isPresented: $isPresentingMappingCreation) {
            NavigationStack {
                MappingEditView(
                    rule: nil,
                    isPresented: $isPresentingMappingCreation,
                    prefilledOriginal: pendingOriginalForMapping
                )
            }
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

    var selectedSourceText: String? {
        guard let selection = sourceSelection else {
            return nil
        }
        let rangeSet: RangeSet<String.Index>
        switch selection.indices {
        case let .selection(range):
            rangeSet = .init(range)
        case let .multiSelection(set):
            rangeSet = set
        @unknown default:
            return nil
        }
        guard let range = rangeSet.ranges.first else {
            return nil
        }
        let trimmed = String(controller.sourceText[range])
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : String(trimmed)
    }

    @ViewBuilder
    func content(
        proxy: GeometryProxy,
        controller: MaskingController
    ) -> some View {
        VStack(spacing: 16) {
            originalSection(proxy: proxy, controller: controller)
            maskedSection(proxy: proxy, controller: controller)
            historySection(controller: controller)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }

    @ViewBuilder
    func originalSection(
        proxy: GeometryProxy,
        controller _: MaskingController
    ) -> some View {
        SectionContainer(title: "Original text") {
            TextEditor(
                text: $controller.sourceText,
                selection: $sourceSelection
            )
            .frame(
                minHeight: 180,
                maxHeight: max(220, proxy.size.height * 0.6)
            )
            Button {
                presentMappingFromSelection()
            } label: {
                Label("Create mapping from selection", systemImage: "plus")
            }
            .disabled(selectedSourceText == nil)
        }
    }

    @ViewBuilder
    func maskedSection(
        proxy: GeometryProxy,
        controller: MaskingController
    ) -> some View {
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
    }

    @ViewBuilder
    func historySection(
        controller: MaskingController
    ) -> some View {
        if controller.result != nil {
            SectionContainer {
                Button {
                    controller.anonymize(
                        context: context,
                        options: maskingOptions(),
                        manualRules: activeManualRules(),
                        shouldSaveHistory: true,
                        isHistoryAutoSaveEnabled: isHistoryAutoSaveEnabled
                    )
                } label: {
                    Label("Save to history", systemImage: "tray.and.arrow.down")
                }
            }
        }
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
        pendingOriginalForMapping = selectedSourceText
        isPresentingMappingCreation = true
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
            isURLMaskingEnabled: isURLMaskingEnabled,
            isEmailMaskingEnabled: isEmailMaskingEnabled,
            isPhoneMaskingEnabled: isPhoneMaskingEnabled
        )
    }
}
