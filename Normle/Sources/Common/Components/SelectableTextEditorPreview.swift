//
//  SelectableTextEditorPreview.swift
//  Normle
//
//  Created by Hiromu Nakano on 2026/03/03.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import SwiftUI

#Preview("SelectableTextEditor - Base") {
    SelectableTextEditorPreview()
}

private struct SelectableTextEditorPreview: View {
    private enum Layout {
        static let minimumHeight = 140.0
    }

    @State private var text = "Select this text to test selection."
    @State private var selectedText = String()

    var body: some View {
        SelectableTextEditor(
            text: $text,
            selectedText: $selectedText,
            onCreateMapping: nil
        )
        .frame(minHeight: Layout.minimumHeight)
        .padding()
    }
}
