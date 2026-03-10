//
//  BaseTransformViewPreview.swift
//  Normle
//
//  Created by Hiromu Nakano on 2026/03/03.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import NormleLibrary
import SwiftData
import SwiftUI

#Preview("Transforms") {
    let container = PreviewData.makeContainer()
    PreviewData.seed(container: container)
    let assembly = NormleAppAssembly.preview(container: container)
    return assembly.previewRootView(
        NavigationStack {
            BaseTransformView()
        }
    )
}
