//
//  TransformsHomeView.swift
//
//
//  Created by Hiromu Nakano on 2025/11/23.
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
