//
//  BaseTransformInputSection.swift
//  Normle
//
//  Created by Hiromu Nakano on 2026/03/03.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import SwiftUI
import TipKit
import UniformTypeIdentifiers

struct BaseTransformInputSection: View {
    private enum Layout {
        static let editorMinHeight = 160.0
        static let qrImageSpacing = 8.0
    }

    let isQRCodeInput: Bool
    @Binding var sourceText: String
    @Binding var selectedSourceText: String
    let importedImageName: String?
    @Binding var isImporterPresented: Bool
    let hasSelectedImage: Bool
    let canCreateMappingFromSelection: Bool
    let sectionRowInsets: EdgeInsets
    let createMappingFromSelection: (String) -> Void
    let createMappingFromCurrentSelection: () -> Void
    let pasteSourceText: () -> Void
    let clearSourceText: () -> Void
    let clearSelectedImage: () -> Void
    let handleDrop: ([NSItemProvider]) -> Void

    var body: some View {
        if isQRCodeInput {
            qrImageSection
        } else {
            sourceTextSection
        }
    }

    var sourceTextSection: some View {
        Section {
            TipView(TransformSelectionMappingTip())
                .tipViewStyle(.miniTip)

            SelectableTextEditor(
                text: $sourceText,
                selectedText: $selectedSourceText
            ) { selectedText in
                createMappingFromSelection(selectedText)
            }
            .frame(minHeight: Layout.editorMinHeight)
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
                createMappingFromCurrentSelection()
            } label: {
                Label("Create mapping from selection", systemImage: "plus")
            }
            .disabled(canCreateMappingFromSelection == false)
            .secondaryActionStyle()
            #endif
        } header: {
            Text("Input")
        } footer: {
            Text("Paste or type text to transform. You can also select text to create a mapping.")
        }
        .listRowInsets(sectionRowInsets)
    }

    var qrImageSection: some View {
        Section {
            VStack(alignment: .leading, spacing: Layout.qrImageSpacing) {
                Text(importedImageName ?? String(localized: "Drop an image or select a file."))
                    .foregroundStyle(importedImageName == nil ? .secondary : .primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                    .onDrop(of: [UTType.image.identifier], isTargeted: nil) { providers in
                        handleDrop(providers)
                        return true
                    }

                Button {
                    isImporterPresented = true
                } label: {
                    Label("Select image", systemImage: "photo.on.rectangle")
                }
                .secondaryActionStyle()

                if hasSelectedImage {
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
}
