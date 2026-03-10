//
//  BaseTransformView.swift
//  Normle
//
//  Created by Hiromu Nakano on 2025/11/23.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import NormleLibrary
import SwiftData
import SwiftUI
import TipKit
import UniformTypeIdentifiers

struct BaseTransformView: View {
    private enum Layout {
        static let horizontalPadding = 16.0
        static let listRowSpacing = 16.0
        static let compactInset = 16.0
        static let wideInset = 24.0
        static let iOSRowInsets = EdgeInsets(
            top: compactInset,
            leading: compactInset,
            bottom: compactInset,
            trailing: compactInset
        )
        static let macOSRowInsets = EdgeInsets(
            top: compactInset,
            leading: wideInset,
            bottom: compactInset,
            trailing: wideInset
        )
    }

    @Environment(\.modelContext)
    private var context
    @EnvironmentObject private var preferencesStore: UserPreferencesStore

    @Query private var mappingRules: [MappingRule]

    @State private var sourceText = String()
    @State private var presetSelectionState = TransformPresetSelectionState()
    @State private var resultText = String()
    @State private var alertMessage: String?
    @State private var qrImage: Image?
    @State private var selectedImageData: Data?
    @State private var importedImageName: String?
    @State private var isImporterPresented = false
    @State private var isPresetSelectorPresented = false
    @State private var selectedSourceText = String()
    @State private var isPresentingMappingCreation = false
    @State private var pendingSourceForMapping = String()
    var body: some View {
        Form {
            inputSection
            resultSection
            actionSection
        }
        .navigationTitle("Transforms")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        #if os(macOS)
        .listStyle(.inset)
        .padding(.horizontal, Layout.horizontalPadding)
        #else
        .listStyle(.insetGrouped)
        #endif
        #if os(iOS)
        .listRowSpacing(Layout.listRowSpacing)
        #endif
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    openPresetSelector()
                } label: {
                    Label("Presets", systemImage: "slider.horizontal.3")
                }
                .popoverTip(TransformPresetTip())
            }
        }
        .sheet(isPresented: $isPresetSelectorPresented) {
            presetSelectionSheet
        }
        .sheet(isPresented: $isPresentingMappingCreation) {
            mappingCreationSheet
        }
        .task {
            applyPresetSelection(preferencesStore.preferences.presetSelection)
        }
        .onChange(of: preferencesStore.preferences) { _, newValue in
            applyPresetSelection(newValue.presetSelection)
        }
        .alert(
            "Transform failed",
            isPresented: Binding(
                get: { alertMessage != nil },
                set: { isPresented in
                    if isPresented == false {
                        alertMessage = nil
                    }
                }
            ),
            presenting: alertMessage
        ) { _ in
            Button("OK", role: .cancel) {
                alertMessage = nil
            }
        } message: { message in
            Text(message)
        }
        .fileImporter(
            isPresented: $isImporterPresented,
            allowedContentTypes: [.image]
        ) { result in
            handleImageImport(result)
        }
    }
}
private extension BaseTransformView {
    var orderedSelectedTransforms: [TransformPreset] {
        presetSelectionState.orderedSelectedPresets
    }
    var presetSelectionSheet: some View {
        BaseTransformViewPresetSheet(
            isPresented: $isPresetSelectorPresented,
            transformGroups: transformGroups,
            isCustomDisabled: isCustomDisabled,
            isGroupDisabled: isGroupDisabled(group:),
            customSelectionBinding: customSelectionBinding(),
            groupSelectionBinding: groupSelectionBinding(for:),
            maskingToggleBinding: maskingToggleBinding(_:)
        )
    }
    var isCustomDisabled: Bool {
        presetSelectionState.isCustomDisabled
    }
    var activeMaskRules: [MaskingRule] {
        mappingRules
            .filter(\.isEnabled)
            .map(\.maskingRule)
    }
    var transformGroups: [TransformGroup] {
        presetSelectionState.transformGroups
    }
    var inputSection: some View {
        BaseTransformInputSection(
            isQRCodeInput: presetSelectionState.selectedPresets.contains(.qrDecode),
            sourceText: $sourceText,
            selectedSourceText: $selectedSourceText,
            importedImageName: importedImageName,
            isImporterPresented: $isImporterPresented,
            hasSelectedImage: selectedImageData != nil,
            canCreateMappingFromSelection: selectedSourceTextValue != nil,
            sectionRowInsets: sectionRowInsets,
            createMappingFromSelection: presentMappingFromSelection(text:),
            createMappingFromCurrentSelection: presentMappingFromSelection,
            pasteSourceText: pasteSourceText,
            clearSourceText: clearSourceText,
            clearSelectedImage: clearSelectedImage,
            handleDrop: handleDrop(providers:)
        )
    }
    var resultSection: some View {
        BaseTransformResultSection(
            isQREncode: presetSelectionState.selectedPresets.contains(.qrEncode),
            resultText: resultText,
            qrImage: qrImage,
            sourceText: sourceText,
            sectionRowInsets: sectionRowInsets
        )
    }
    var actionSection: some View {
        BaseTransformActionSection(
            isDisabled: isRunDisabled,
            sectionRowInsets: sectionRowInsets,
            runTransform: runTransform
        )
    }
    var mappingCreationSheet: some View {
        NavigationStack {
            MappingEditView(
                rule: nil,
                isPresented: $isPresentingMappingCreation,
                prefilledSource: pendingSourceForMapping
            )
        }
    }
    var sectionRowInsets: EdgeInsets {
        #if os(macOS)
        return Layout.macOSRowInsets
        #else
        return Layout.iOSRowInsets
        #endif
    }
    var selectedSourceTextValue: String? {
        let trimmed = selectedSourceText.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
    var isRunDisabled: Bool {
        if presetSelectionState.selectedPresets.isEmpty {
            return true
        }
        if presetSelectionState.selectedPresets.contains(.qrEncode) {
            return sourceText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        if presetSelectionState.selectedPresets.contains(.qrDecode) {
            return selectedImageData == nil
        }
        return sourceText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
private extension BaseTransformView {
    func customSelectionBinding() -> Binding<Bool> {
        Binding(
            get: {
                presetSelectionState.selectedPresets.contains(.customMapping)
            },
            set: { isSelected in
                updateCustomSelection(isSelected: isSelected)
            }
        )
    }
    func groupSelectionBinding(for group: TransformGroup) -> Binding<TransformPreset?> {
        Binding(
            get: {
                presetSelectionState.selectedPreset(in: group)
            },
            set: { selectedPreset in
                updateGroupSelection(
                    group: group,
                    selectedPreset: selectedPreset
                )
            }
        )
    }
    func updateCustomSelection(isSelected: Bool) {
        presetSelectionState.updateCustomSelection(isSelected: isSelected)
        syncPresetSelection()
        resetSelectionState()
    }
    func openPresetSelector() {
        NormleTipManager.donate(NormleTipEvents.didOpenPresetSelector)
        TransformPresetTip().invalidate(reason: .actionPerformed)
        isPresetSelectorPresented = true
    }
    func updateGroupSelection(
        group: TransformGroup,
        selectedPreset: TransformPreset?
    ) {
        presetSelectionState.updateGroupSelection(
            group: group,
            selectedPreset: selectedPreset
        )
        syncPresetSelection()
        resetSelectionState()
    }
    func isGroupDisabled(group: TransformGroup) -> Bool {
        presetSelectionState.isGroupDisabled(group)
    }
    func resetSelectionState() {
        resultText = String()
        qrImage = nil
        alertMessage = nil
    }
    func startMappingCreation(prefilledSource: String) {
        pendingSourceForMapping = prefilledSource
        NormleTipManager.donate(NormleTipEvents.didStartMappingFromSelection)
        NormleTipManager.donate(NormleTipEvents.didStartMappingCreation)
        TransformSelectionMappingTip().invalidate(reason: .actionPerformed)
        MappingAddTip().invalidate(reason: .actionPerformed)
        isPresentingMappingCreation = true
    }
    func presentMappingFromSelection() {
        guard let selectedSourceTextValue else {
            return
        }
        startMappingCreation(prefilledSource: selectedSourceTextValue)
    }
    func presentMappingFromSelection(text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else {
            return
        }
        startMappingCreation(prefilledSource: trimmed)
    }
    func maskingOptions() -> MaskingOptions {
        preferencesStore.preferences.maskingPreferences.maskingOptions
    }
    func maskingToggleBinding(
        _ keyPath: WritableKeyPath<MaskingPreferences, Bool>
    ) -> Binding<Bool> {
        Binding(
            get: {
                preferencesStore.preferences.maskingPreferences[keyPath: keyPath]
            },
            set: { newValue in
                preferencesStore.update { preferences in
                    preferences.maskingPreferences[keyPath: keyPath] = newValue
                }
            }
        )
    }
    func applyPresetSelection(_ selection: PresetSelection) {
        presetSelectionState.applyPresetSelection(selection)
    }
    func syncPresetSelection() {
        let selection = presetSelectionState.presetSelection()
        preferencesStore.update { preferences in
            preferences.presetSelection = selection
        }
    }
    func runTransform() {
        let result = TransformExecutionService(context: context).runAndSave(
            sourceText: sourceText,
            presets: orderedSelectedTransforms,
            maskRules: activeMaskRules,
            options: maskingOptions(),
            imageData: selectedImageData
        )
        switch result {
        case .success(let output):
            alertMessage = nil
            resultText = output.outputText
            if let image = output.qrImage {
                qrImage = Image(decorative: image, scale: 1, orientation: .up)
            } else {
                qrImage = nil
            }
        case .failure(let error):
            qrImage = nil
            resultText = String()
            switch error {
            case .pipeline(let pipelineError):
                if pipelineError == .missingImageData {
                    alertMessage = String(localized: "Select an image to decode.")
                } else {
                    alertMessage = pipelineError.localizedDescription
                }
            case .persistence(let persistenceError):
                alertMessage = persistenceError.localizedDescription
            }
        }
    }
    func pasteSourceText() {
        guard let pastedText = ClipboardService.pasteText() else {
            return
        }
        sourceText = pastedText
        resultText = String()
        qrImage = nil
    }
    func clearSourceText() {
        sourceText = String()
        resultText = String()
        qrImage = nil
        alertMessage = nil
    }
    func clearSelectedImage() {
        selectedImageData = nil
        importedImageName = nil
        resultText = String()
        qrImage = nil
        alertMessage = nil
    }
    func handleDrop(providers: [NSItemProvider]) {
        guard let provider = providers.first(where: { provider in
            provider.hasItemConformingToTypeIdentifier(UTType.image.identifier)
        }) else {
            return
        }
        let suggestedName = provider.suggestedName
        provider.loadDataRepresentation(forTypeIdentifier: UTType.image.identifier) { data, _ in
            guard let data else {
                return
            }
            DispatchQueue.main.async {
                selectedImageData = data
                importedImageName = suggestedName
                resultText = String()
            }
        }
    }
    func handleImageImport(_ result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            do {
                let data = try Data(contentsOf: url)
                selectedImageData = data
                importedImageName = url.lastPathComponent
                resultText = String()
            } catch {
                alertMessage = error.localizedDescription
            }
        case .failure(let error):
            alertMessage = error.localizedDescription
        }
    }
}
