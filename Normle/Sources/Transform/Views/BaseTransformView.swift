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

    @State private var sourceText = String()
    @State private var selectedTransform = BaseTransform.allCases.first ?? .lowercase
    @State private var resultText = String()
    @State private var alertMessage: String?
    @State private var qrImage: Image?
    @State private var selectedImageData: Data?
    @State private var importedImageName: String?
    @State private var isImporterPresented = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if selectedTransform != .qrDecode {
                    SectionContainer(title: "Source text") {
                        TextEditor(text: $sourceText)
                            .frame(minHeight: 160)
                    }
                } else {
                    SectionContainer(title: "QR image") {
                        VStack(alignment: .leading, spacing: 8) {
                            DropAreaView(isActive: selectedImageData != nil) {
                                if let name = importedImageName {
                                    Text(name).font(.subheadline)
                                } else {
                                    Text("Drop an image or select a file.")
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .onDrop(of: [UTType.image.identifier], isTargeted: nil) { providers in
                                handleDrop(providers: providers)
                                return true
                            }

                            Button {
                                isImporterPresented = true
                            } label: {
                                Label("Select image", systemImage: "photo.on.rectangle")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                }

                SectionContainer(title: "Preset") {
                    Picker("Preset", selection: $selectedTransform) {
                        ForEach(BaseTransform.allCases) { preset in
                            Text(preset.title).tag(preset)
                        }
                    }
                    .pickerStyle(.inline)
                }

                SectionContainer(title: "Result") {
                    resultContent
                }

                Button {
                    runTransform()
                } label: {
                    Label("Transform & Save", systemImage: "arrow.triangle.2.circlepath")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(isRunDisabled)
            }
            .padding()
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
            Button("OK", role: .cancel) {}
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
        switch selectedTransform {
        case .qrEncode:
            return sourceText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .qrDecode:
            return selectedImageData == nil
        default:
            return sourceText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }

    @ViewBuilder
    var resultContent: some View {
        switch selectedTransform {
        case .qrEncode:
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
        default:
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
        switch selectedTransform {
        case .qrEncode:
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
        case .qrDecode:
            guard let imageData = selectedImageData else {
                alertMessage = "Select an image to decode."
                return
            }
            let result = selectedTransform.apply(text: String(), imageData: imageData)
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
        default:
            let result = selectedTransform.apply(text: sourceText)
            switch result {
            case .success(let output):
                alertMessage = nil
                resultText = output
                saveRecord(source: sourceText, target: output)
            case .failure(let error):
                resultText = String()
                alertMessage = error.localizedDescription
            }
        }
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
        guard let provider = providers.first(where: { $0.hasItemConformingToTypeIdentifier(UTType.image.identifier) }) else {
            return
        }
        provider.loadDataRepresentation(forTypeIdentifier: UTType.image.identifier) { data, _ in
            guard let data else { return }
            DispatchQueue.main.async {
                selectedImageData = data
                importedImageName = provider.suggestedName
                resultText = String()
            }
        }
    }
}

private struct SectionContainer<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
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

private struct DropAreaView<Content: View>: View {
    let isActive: Bool
    @ViewBuilder let content: Content

    var body: some View {
        VStack {
            content
        }
        .frame(maxWidth: .infinity, minHeight: 160)
        .padding()
        .background(isActive ? Color.accentColor.opacity(0.1) : Color(.systemBackground))
        .clipShape(.rect(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(
                    isActive ? Color.accentColor : Color.secondary.opacity(0.4),
                    lineWidth: 1
                )
        )
    }
}
