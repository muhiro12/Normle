//
//  BaseTransformActionSection.swift
//  Normle
//
//  Created by Hiromu Nakano on 2026/03/03.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct BaseTransformActionSection: View {
    let isDisabled: Bool
    let sectionRowInsets: EdgeInsets
    let runTransform: () -> Void

    var body: some View {
        Section {
            #if os(macOS)
            HStack {
                Spacer()
                Button {
                    runTransform()
                } label: {
                    Label("Transform & Save", systemImage: "arrow.triangle.2.circlepath")
                }
                .disabled(isDisabled)
                .primaryActionStyle()
            }
            #else
            Button {
                runTransform()
            } label: {
                Label("Transform & Save", systemImage: "arrow.triangle.2.circlepath")
            }
            .disabled(isDisabled)
            .primaryActionStyle()
            #endif
        }
        .listRowInsets(sectionRowInsets)
    }
}
