//
//  BaseTransformView.swift
//
//
//  Created by Hiromu Nakano on 2025/11/23.
//

import NormleLibrary
import SwiftData
import SwiftUI
import UniformTypeIdentifiers

struct BaseTransformView: View {
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
            if presetSelectionState.selectedPresets.contains(.qrDecode) == false {
                Section {
                    SelectableTextEditor(
                        text: $sourceText,
                        selectedText: $selectedSourceText
                    ) { selectedText in
                        presentMappingFromSelection(text: selectedText)
                    }
                    .frame(minHeight: 160)
                    .liquidGlassEffect()
                    Button {
                        pasteSourceText()
                    } label: {
                        Label("Paste", systemImage: "doc.on.clipboard")
                    }
                    .secondaryActionStyle()
                    Button {
                        clearSourceText()
                    } label: {
                        Label("Clear", systemImage: "xmark.circle")
                    }
                    .secondaryActionStyle()
                    #if os(macOS)
                    Button {
                        presentMappingFromSelection()
                    } label: {
                        Label("Create mapping from selection", systemImage: "plus")
                    }
                    .disabled(selectedSourceTextValue == nil)
                    .secondaryActionStyle()
                    #endif
                } header: {
                    Text("Input")
                } footer: {
                    Text("Paste or type text to transform. You can also select text to create a mapping.")
                }
                .listRowInsets(sectionRowInsets)
            } else {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(importedImageName ?? String(localized: "Drop an image or select a file."))
                            .foregroundStyle(importedImageName == nil ? .secondary : .primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .contentShape(Rectangle())
                            .onDrop(of: [UTType.image.identifier], isTargeted: nil) { providers in
                                handleDrop(providers: providers)
                                return true
                            }

                        Button {
                            isImporterPresented = true
                        } label: {
                            Label("Select image", systemImage: "photo.on.rectangle")
                        }
                        .secondaryActionStyle()
                        if selectedImageData != nil {
                            Button {
                                clearSelectedImage()
                            } label: {
                                Label("Clear image", systemImage: "xmark.circle")
                            }
                            .secondaryActionStyle()
                        }
                    }
                } header: {
                    Text("QR Image")
                } footer: {
                    Text("Drop or choose a QR image to decode.")
                }
                .listRowInsets(sectionRowInsets)
            }

            Section("Result") {
                resultContent
            }
            .listRowInsets(sectionRowInsets)

            Section {
                #if os(macOS)
                HStack {
                    Spacer()
                    Button {
                        runTransform()
                    } label: {
                        Label("Transform & Save", systemImage: "arrow.triangle.2.circlepath")
                    }
                    .disabled(isRunDisabled)
                    .primaryActionStyle()
                }
                #else
                Button {
                    runTransform()
                } label: {
                    Label("Transform & Save", systemImage: "arrow.triangle.2.circlepath")
                }
                .disabled(isRunDisabled)
                .primaryActionStyle()
                #endif
            }
            .listRowInsets(sectionRowInsets)
        }
        .navigationTitle("Transforms")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        #if os(macOS)
        .listStyle(.inset)
        .padding(.horizontal, 16)
        #else
        .listStyle(.insetGrouped)
        #endif
        #if os(iOS)
        .listRowSpacing(16)
        #endif
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    isPresetSelectorPresented = true
                } label: {
                    Label("Presets", systemImage: "slider.horizontal.3")
                }
            }
        }
        .sheet(isPresented: $isPresetSelectorPresented) {
            presetSelectionSheet
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
            }
        } message: { message in
            Text(message)
        }
        .fileImporter(
            isPresented: $isImporterPresented,
            allowedContentTypes: [.image]
        ) { result in
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
}

private extension BaseTransformView {
    var sectionRowInsets: EdgeInsets {
        #if os(macOS)
        return .init(top: 16, leading: 24, bottom: 16, trailing: 24)
        #else
        return .init(top: 16, leading: 16, bottom: 16, trailing: 16)
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

    @ViewBuilder
    var resultContent: some View {
        if presetSelectionState.selectedPresets.contains(.qrEncode) {
            if let qrImage {
                qrImage
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .frame(maxWidth: 240, maxHeight: 240)
                    .frame(maxWidth: .infinity)
                CopyButton(text: sourceText)
            } else {
                ContentUnavailableView(
                    "No QR Code",
                    systemImage: "qrcode",
                    description: Text("Enter text, then run QR Encode.")
                )
            }
        } else {
            if resultText.isEmpty {
                ContentUnavailableView(
                    "No Result",
                    systemImage: "sparkles",
                    description: Text("Select a preset and run transform.")
                )
            } else {
                TextEditor(text: .constant(resultText))
                    .frame(minHeight: 160)
                    .textSelection(.enabled)
                    .liquidGlassEffect()
                CopyButton(text: resultText)
            }
        }
    }

    func runTransform() {
        let pipeline = TransformPipeline()
        let result = pipeline.run(
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
            saveRecord(source: output.recordSourceText, target: output.recordTargetText)
        case .failure(let error):
            qrImage = nil
            resultText = String()
            if error == .missingImageData {
                alertMessage = String(localized: "Select an image to decode.")
            } else {
                alertMessage = error.localizedDescription
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

    func saveRecord(source: String?, target: String) {
        do {
            _ = try TransformRecordService.saveRecord(
                context: context,
                sourceText: source,
                targetText: target,
                mappings: []
            )
        } catch {
            assertionFailure(error.localizedDescription)
        }
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
}

private extension BaseTransformView {
    var orderedSelectedTransforms: [TransformPreset] {
        presetSelectionState.orderedSelectedPresets
    }

    var presetSelectionSheet: some View {
        NavigationStack {
            Form {
                Section("Masking Options") {
                    Toggle(isOn: maskingToggleBinding(\.isURLMaskingEnabled)) {
                        Text("Mask URLs")
                    }
                    Toggle(isOn: maskingToggleBinding(\.isEmailMaskingEnabled)) {
                        Text("Mask emails")
                    }
                    Toggle(isOn: maskingToggleBinding(\.isPhoneMaskingEnabled)) {
                        Text("Mask phone numbers")
                    }
                }

                Section("Custom") {
                    Picker("Custom", selection: customSelectionBinding()) {
                        Text("None")
                            .tag(false)
                        Text(TransformPreset.customMapping.title)
                            .tag(true)
                    }
                    .pickerStyle(.segmented)
                    .disabled(isCustomDisabled)
                    Text("Applied first.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                ForEach(transformGroups) { group in
                    Section(group.title) {
                        Picker(group.title, selection: groupSelectionBinding(for: group)) {
                            Text("None")
                                .tag(Optional<TransformPreset>.none)
                            ForEach(group.options) { option in
                                Text(option.title)
                                    .tag(TransformPreset?.some(option))
                            }
                        }
                        .pickerStyle(.segmented)
                        .disabled(isGroupDisabled(group: group))
                    }
                }
            }
            .navigationTitle("Presets")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        isPresetSelectorPresented = false
                    }
                }
            }
        }
    }

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
                updateGroupSelection(group: group, selectedPreset: selectedPreset)
            }
        )
    }

    func updateCustomSelection(isSelected: Bool) {
        presetSelectionState.updateCustomSelection(isSelected: isSelected)
        syncPresetSelection()
        resetSelectionState()
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

    var isCustomDisabled: Bool {
        presetSelectionState.isCustomDisabled
    }

    func isGroupDisabled(group: TransformGroup) -> Bool {
        presetSelectionState.isGroupDisabled(group)
    }

    func resetSelectionState() {
        resultText = String()
        qrImage = nil
        alertMessage = nil
    }

    func presentMappingFromSelection() {
        guard let selectedSourceTextValue else {
            return
        }
        pendingSourceForMapping = selectedSourceTextValue
        isPresentingMappingCreation = true
    }

    func presentMappingFromSelection(text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else {
            return
        }
        pendingSourceForMapping = trimmed
        isPresentingMappingCreation = true
    }

    var activeMaskRules: [MaskingRule] {
        mappingRules
            .filter(\.isEnabled)
            .map(\.maskingRule)
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

    var transformGroups: [TransformGroup] {
        presetSelectionState.transformGroups
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
}

private extension View {
    @ViewBuilder
    func secondaryActionStyle() -> some View {
        #if os(macOS)
        self.buttonStyle(.borderless)
        #else
        self.buttonStyle(.bordered)
        #endif
    }

    @ViewBuilder
    func primaryActionStyle() -> some View {
        #if os(macOS)
        self.buttonStyle(.borderedProminent)
            .controlSize(.regular)
        #else
        self.buttonStyle(.borderedProminent)
        #endif
    }
}

#Preview("Transforms") {
    let container = PreviewData.makeContainer()
    PreviewData.seed(container: container)
    let preferencesStore = UserPreferencesStore()
    return NavigationStack {
        BaseTransformView()
    }
    .modelContainer(container)
    .environmentObject(preferencesStore)
}
