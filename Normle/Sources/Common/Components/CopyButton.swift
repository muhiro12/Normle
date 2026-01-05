//
//  CopyButton.swift
//
//
//  Created by Hiromu Nakano on 2025/11/23.
//

import SwiftUI

struct CopyButton: View {
    private let text: String
    private let labelKey: String

    init(
        _ label: String = "Copy",
        text: String
    ) {
        self.text = text
        labelKey = label
    }

    var body: some View {
        Button {
            ClipboardService.copy(text)
        } label: {
            Label(String(localized: .init(labelKey)), systemImage: "doc.on.doc")
        }
    }
}
