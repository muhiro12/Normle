//
//  CopyButton.swift
//
//
//  Created by Hiromu Nakano on 2025/11/23.
//

import SwiftUI

struct CopyButton: View {
    private let text: String
    private let label: String

    init(
        _ label: String = "Copy",
        text: String
    ) {
        self.text = text
        self.label = label
    }

    var body: some View {
        Button {
            ClipboardService.copy(text)
        } label: {
            Label(label, systemImage: "doc.on.doc")
        }
    }
}
