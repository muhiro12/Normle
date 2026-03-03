//
//  TransformsHomeView.swift
//  Normle
//
//  Created by Hiromu Nakano on 2025/11/23.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import NormleLibrary
import SwiftData
import SwiftUI

struct TransformsHomeView: View {
    var body: some View {
        BaseTransformView()
            .navigationTitle("Transforms")
    }
}

#Preview("Transforms - Home") {
    let container = PreviewData.makeContainer()
    PreviewData.seed(container: container)
    let preferencesStore = UserPreferencesStore()
    return NavigationStack {
        TransformsHomeView()
    }
    .modelContainer(container)
    .environmentObject(preferencesStore)
}
