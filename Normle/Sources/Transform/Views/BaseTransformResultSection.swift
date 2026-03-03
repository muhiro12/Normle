//
//  BaseTransformResultSection.swift
//  Normle
//
//  Created by Hiromu Nakano on 2026/03/03.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct BaseTransformResultSection: View {
    private enum Layout {
        static let editorMinHeight = 160.0
        static let qrPreviewMaxSize = 240.0
    }

    let isQREncode: Bool
    let resultText: String
    let qrImage: Image?
    let sourceText: String
    let sectionRowInsets: EdgeInsets

    var body: some View {
        Section("Result") {
            resultContent
        }
        .listRowInsets(sectionRowInsets)
    }

    @ViewBuilder var resultContent: some View {
        if isQREncode {
            if let qrImage {
                qrImage
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .frame(
                        maxWidth: Layout.qrPreviewMaxSize,
                        maxHeight: Layout.qrPreviewMaxSize
                    )
                    .frame(maxWidth: .infinity)
                CopyButton(text: sourceText)
            } else {
                ContentUnavailableView(
                    "No QR Code",
                    systemImage: "qrcode",
                    description: Text("Enter text, then run QR Encode.")
                )
            }
        } else if resultText.isEmpty {
            ContentUnavailableView(
                "No Result",
                systemImage: "sparkles",
                description: Text("Select a preset and run transform.")
            )
        } else {
            TextEditor(text: .constant(resultText))
                .frame(minHeight: Layout.editorMinHeight)
                .textSelection(.enabled)
                .liquidGlassEffect()
            CopyButton(text: resultText)
        }
    }
}
