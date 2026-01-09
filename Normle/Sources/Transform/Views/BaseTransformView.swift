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

    @AppStorage(.isURLMaskingEnabled)
    private var isURLMaskingEnabled = true
    @AppStorage(.isEmailMaskingEnabled)
    private var isEmailMaskingEnabled = true
    @AppStorage(.isPhoneMaskingEnabled)
    private var isPhoneMaskingEnabled = true

    @Query private var mappingRules: [MappingRule]

    @State private var sourceText = String()
    @State private var selectedTransforms: Set<TransformPreset> = {
        if let firstPreset = TransformPreset.allCases.first {
            return [firstPreset]
        }
        return []
    }()
    @State private var resultText = String()
    @State private var alertMessage: String?
    @State private var qrImage: Image?
    @State private var selectedImageData: Data?
    @State private var importedImageName: String?
    @State private var isImporterPresented = false

    var body: some View {
        Form {
            if selectedTransforms.contains(qrDecodePreset) == false {
                Section("Source text") {
                    TextEditor(text: $sourceText)
                        .frame(minHeight: 160)
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
                }
            } else {
                Section("QR image") {
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
                        if selectedImageData != nil {
                            Button {
                                clearSelectedImage()
                            } label: {
                                Label("Clear image", systemImage: "xmark.circle")
                            }
                        }
                    }
                }
            }

            Section("Preset") {
                Picker("Custom", selection: customSelectionBinding()) {
                    Text("None")
                        .tag(false)
                    Text(customMappingPreset.title)
                        .tag(true)
                }
                .pickerStyle(.segmented)
                .disabled(isCustomDisabled)
                Text("Applied first.")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                ForEach(transformGroups) { group in
                    Picker(group.title, selection: groupSelectionBinding(for: group)) {
                        Text("None").tag(Optional<TransformPreset>.none)
                        ForEach(group.options) { option in
                            Text(option.title)
                                .tag(TransformPreset?.some(option))
                        }
                    }
                    .pickerStyle(.segmented)
                    .disabled(isGroupDisabled(group: group))
                }
            }

            Section("Result") {
                resultContent
            }

            Section {
                Button {
                    runTransform()
                } label: {
                    Label("Transform & Save", systemImage: "arrow.triangle.2.circlepath")
                }
                .disabled(isRunDisabled)
            }
        }
        .navigationTitle("Transforms")
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
    var isRunDisabled: Bool {
        if selectedTransforms.isEmpty {
            return true
        }
        if selectedTransforms.contains(qrEncodePreset) {
            return sourceText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        if selectedTransforms.contains(qrDecodePreset) {
            return selectedImageData == nil
        }
        return sourceText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    @ViewBuilder
    var resultContent: some View {
        if selectedTransforms.contains(qrEncodePreset) {
            if let qrImage {
                qrImage
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .frame(maxWidth: 240, maxHeight: 240)
                    .frame(maxWidth: .infinity)
                CopyButton(text: sourceText)
            } else {
                Text("Enter text and run QR Encode.")
                    .foregroundStyle(.secondary)
            }
        } else {
            if resultText.isEmpty {
                Text("Select a preset and run transform.")
                    .foregroundStyle(.secondary)
            } else {
                TextEditor(text: .constant(resultText))
                    .frame(minHeight: 160)
                    .textSelection(.enabled)
                CopyButton(text: resultText)
            }
        }
    }

    func runTransform() {
        if selectedTransforms.contains(qrEncodePreset) {
            let generation = BaseTransform.qrEncode.qrCodeImage(for: sourceText)
            switch generation {
            case .success(let image):
                qrImage = Image(decorative: image, scale: 1, orientation: .up)
                resultText = String()
                alertMessage = nil
                saveRecord(source: sourceText, target: String())
            case .failure(let error):
                qrImage = nil
                resultText = String()
                alertMessage = error.localizedDescription
            }
        } else if selectedTransforms.contains(qrDecodePreset) {
            guard let imageData = selectedImageData else {
                alertMessage = String(localized: "Select an image to decode.")
                return
            }
            let result = BaseTransform.qrDecode.apply(text: String(), imageData: imageData)
            switch result {
            case .success(let output):
                alertMessage = nil
                qrImage = nil
                resultText = output
                saveRecord(source: String(), target: output)
            case .failure(let error):
                resultText = String()
                alertMessage = error.localizedDescription
            }
        } else {
            applyTransformsToText()
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

    func saveRecord(source: String, target: String) {
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
        var orderedPresets = [TransformPreset]()
        if selectedTransforms.contains(customMappingPreset) {
            orderedPresets.append(customMappingPreset)
        }
        for transform in BaseTransform.allCases {
            let preset = TransformPreset.builtIn(transform)
            if selectedTransforms.contains(preset) {
                orderedPresets.append(preset)
            }
        }
        return orderedPresets
    }

    func applyTransformsToText() {
        var outputText = sourceText
        for preset in orderedSelectedTransforms {
            switch preset {
            case .builtIn(let transform):
                let result = transform.apply(text: outputText)
                switch result {
                case .success(let transformedText):
                    outputText = transformedText
                case .failure(let error):
                    resultText = String()
                    alertMessage = error.localizedDescription
                    return
                }
            case .customMapping:
                let masked = MaskingService.anonymize(
                    text: outputText,
                    maskRules: activeMaskRules,
                    options: maskingOptions()
                )
                outputText = masked.maskedText
            }
        }
        alertMessage = nil
        resultText = outputText
        saveRecord(source: sourceText, target: outputText)
    }

    func customSelectionBinding() -> Binding<Bool> {
        Binding(
            get: {
                selectedTransforms.contains(customMappingPreset)
            },
            set: { isSelected in
                updateCustomSelection(isSelected: isSelected)
            }
        )
    }

    func groupSelectionBinding(for group: TransformGroup) -> Binding<TransformPreset?> {
        Binding(
            get: {
                for option in group.options {
                    if selectedTransforms.contains(option) {
                        return option
                    }
                }
                return nil
            },
            set: { selectedPreset in
                updateGroupSelection(group: group, selectedPreset: selectedPreset)
            }
        )
    }

    func updateCustomSelection(isSelected: Bool) {
        if isSelected {
            selectedTransforms.remove(qrEncodePreset)
            selectedTransforms.remove(qrDecodePreset)
            selectedTransforms.insert(customMappingPreset)
        } else {
            selectedTransforms.remove(customMappingPreset)
        }
        resetSelectionState()
    }

    func updateGroupSelection(
        group: TransformGroup,
        selectedPreset: TransformPreset?
    ) {
        for option in group.options {
            selectedTransforms.remove(option)
        }
        guard let selectedPreset else {
            resetSelectionState()
            return
        }
        if group.isQRCodeGroup {
            selectedTransforms = [selectedPreset]
        } else {
            selectedTransforms.remove(qrEncodePreset)
            selectedTransforms.remove(qrDecodePreset)
            selectedTransforms.insert(selectedPreset)
        }
        resetSelectionState()
    }

    var isCustomDisabled: Bool {
        isQRSelected
    }

    func isGroupDisabled(group: TransformGroup) -> Bool {
        if group.isQRCodeGroup {
            return selectedTransforms.isEmpty == false && isQRSelected == false
        }
        return isQRSelected
    }

    var isQRSelected: Bool {
        selectedTransforms.contains(qrEncodePreset) ||
            selectedTransforms.contains(qrDecodePreset)
    }

    func resetSelectionState() {
        resultText = String()
        qrImage = nil
        alertMessage = nil
    }

    var activeMaskRules: [MaskingRule] {
        mappingRules
            .filter(\.isEnabled)
            .map(\.maskingRule)
    }

    func maskingOptions() -> MaskingOptions {
        .init(
            isURLMaskingEnabled: isURLMaskingEnabled,
            isEmailMaskingEnabled: isEmailMaskingEnabled,
            isPhoneMaskingEnabled: isPhoneMaskingEnabled
        )
    }

    var qrEncodePreset: TransformPreset {
        .builtIn(.qrEncode)
    }

    var qrDecodePreset: TransformPreset {
        .builtIn(.qrDecode)
    }

    var customMappingPreset: TransformPreset {
        .customMapping
    }

    var transformGroups: [TransformGroup] {
        [
            .init(
                title: String(localized: "Case"),
                options: [
                    .builtIn(.lowercase),
                    .builtIn(.uppercase)
                ],
                isQRCodeGroup: false
            ),
            .init(
                title: String(localized: "Alphanumeric Width"),
                options: [
                    .builtIn(.fullwidthAlphanumericToHalfwidth),
                    .builtIn(.halfwidthAlphanumericToFullwidth)
                ],
                isQRCodeGroup: false
            ),
            .init(
                title: String(localized: "Space Width"),
                options: [
                    .builtIn(.fullwidthSpaceToHalfwidth),
                    .builtIn(.halfwidthSpaceToFullwidth)
                ],
                isQRCodeGroup: false
            ),
            .init(
                title: String(localized: "Katakana Width"),
                options: [
                    .builtIn(.halfwidthKatakanaToFullwidth),
                    .builtIn(.fullwidthKatakanaToHalfwidth)
                ],
                isQRCodeGroup: false
            ),
            .init(
                title: String(localized: "Digits Width"),
                options: [
                    .builtIn(.fullwidthDigitsToHalfwidth),
                    .builtIn(.halfwidthDigitsToFullwidth)
                ],
                isQRCodeGroup: false
            ),
            .init(
                title: String(localized: "Base64"),
                options: [
                    .builtIn(.base64Encode),
                    .builtIn(.base64Decode)
                ],
                isQRCodeGroup: false
            ),
            .init(
                title: String(localized: "URL"),
                options: [
                    .builtIn(.urlEncode),
                    .builtIn(.urlDecode)
                ],
                isQRCodeGroup: false
            ),
            .init(
                title: String(localized: "QR"),
                options: [
                    .builtIn(.qrEncode),
                    .builtIn(.qrDecode)
                ],
                isQRCodeGroup: true
            )
        ]
    }
}

private enum TransformPreset: Hashable, Identifiable {
    case builtIn(BaseTransform)
    case customMapping

    var id: String {
        switch self {
        case .builtIn(let transform):
            return "builtIn_\(transform.id)"
        case .customMapping:
            return "customMapping"
        }
    }

    var title: String {
        switch self {
        case .builtIn(let transform):
            return transform.title
        case .customMapping:
            return String(localized: "Custom")
        }
    }

    var isQRCodeOnly: Bool {
        switch self {
        case .builtIn(let transform):
            return transform == .qrEncode || transform == .qrDecode
        case .customMapping:
            return false
        }
    }

    static var allCases: [Self] {
        let builtIns: [Self] = BaseTransform.allCases.map { transform in
            .builtIn(transform) as Self
        }
        return [
            .customMapping
        ] + builtIns
    }
}

private struct TransformGroup: Identifiable {
    let id: String
    let title: String
    let options: [TransformPreset]
    let isQRCodeGroup: Bool

    init(
        title: String,
        options: [TransformPreset],
        isQRCodeGroup: Bool
    ) {
        self.id = title
        self.title = title
        self.options = options
        self.isQRCodeGroup = isQRCodeGroup
    }
}
