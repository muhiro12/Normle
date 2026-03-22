//
//  CopyButton.swift
//  Normle
//
//  Created by Hiromu Nakano on 2025/11/23.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import MHUI
import SwiftUI

struct CopyButton: View {
    private let text: String
    private let labelKey: String

    var body: some View {
        Button {
            ClipboardService.copy(text)
        } label: {
            Label(String(localized: .init(labelKey)), systemImage: "doc.on.doc")
        }
        .buttonStyle(.mhSecondary)
    }

    init(
        text: String,
        label: String = "Copy"
    ) {
        self.text = text
        labelKey = label
    }
}

#Preview("CopyButton - Base") {
    let assembly = NormleAppAssembly.preview()
    return assembly.previewRootView(
        CopyButton(
            text: "Sample text"
        )
        .padding()
    )
}
