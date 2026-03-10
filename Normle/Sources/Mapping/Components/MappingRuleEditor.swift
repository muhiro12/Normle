//
//  MappingRuleEditor.swift
//  Normle
//
//  Created by Hiromu Nakano on 2025/11/23.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import NormleLibrary
import SwiftUI

struct MappingRuleEditor: View {
    private enum Layout {
        static let spacing = 8.0
    }

    @Binding var rule: MaskingRule

    var body: some View {
        VStack(alignment: .leading, spacing: Layout.spacing) {
            TextField(
                "Source text",
                text: $rule.original,
                axis: .vertical
            )
            .liquidGlassTextFieldStyle()

            TextField(
                "Target text",
                text: $rule.masked,
                axis: .vertical
            )
            .liquidGlassTextFieldStyle()

            Picker("Kind", selection: $rule.kind) {
                ForEach(MappingKind.allCases) { kind in
                    Text(kind.displayName).tag(kind)
                }
            }
            .pickerStyle(.menu)
        }
    }
}

#Preview("MappingRuleEditor - Base") {
    MappingRuleEditor(
        rule: .constant(
            .init(
                original: "Example",
                masked: "[Masked]",
                kind: .custom
            )
        )
    )
    .padding()
}
