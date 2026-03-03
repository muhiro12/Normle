//
//  SelectableTextEditor.swift
//  Normle
//
//  Created by Hiromu Nakano on 2025/11/23.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct SelectableTextEditor: View {
    @Binding var text: String
    @Binding var selectedText: String
    let onCreateMapping: ((String) -> Void)?

    var body: some View {
        SelectableTextView(
            text: $text,
            selectedText: $selectedText,
            onCreateMapping: onCreateMapping
        )
        .liquidGlassEffect()
    }
}
