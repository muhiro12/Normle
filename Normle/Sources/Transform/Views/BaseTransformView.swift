//
//  BaseTransformView.swift
//
//
//  Created by Hiromu Nakano on 2025/11/23.
//

import NormleLibrary
import SwiftData
import SwiftUI

struct BaseTransformView: View {
    @Environment(\.modelContext)
    private var context

    @State private var sourceText = String()
    @State private var selectedTransform = BaseTransform.allCases.first ?? .lowercase
    @State private var resultText = String()
    @State private var alertMessage: String?

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                SectionContainer(title: "Source text") {
                    TextEditor(text: $sourceText)
                        .frame(minHeight: 160)
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

                Button {
                    runTransform()
                } label: {
                    Label("Transform & Save", systemImage: "arrow.triangle.2.circlepath")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(sourceText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
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
    }
}

private extension BaseTransformView {
    func runTransform() {
        let result = selectedTransform.apply(to: sourceText)
        switch result {
        case .success(let output):
            alertMessage = nil
            resultText = output
            do {
                _ = try TransformRecordService.saveRecord(
                    context: context,
                    sourceText: sourceText,
                    targetText: output,
                    mappings: []
                )
            } catch {
                assertionFailure(error.localizedDescription)
            }
        case .failure(let error):
            resultText = String()
            alertMessage = error.localizedDescription
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
