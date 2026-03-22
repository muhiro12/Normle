//
//  BaseTransformActionSection.swift
//  Normle
//
//  Created by Hiromu Nakano on 2026/03/03.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import MHUI
import SwiftUI

struct BaseTransformActionSection: View {
    let isDisabled: Bool
    let runTransform: () -> Void

    var body: some View {
        Section {
            Button {
                runTransform()
            } label: {
                Label("Transform & Save", systemImage: "arrow.triangle.2.circlepath")
            }
            .disabled(isDisabled)
            .buttonStyle(.mhPrimary)
        }
    }
}
