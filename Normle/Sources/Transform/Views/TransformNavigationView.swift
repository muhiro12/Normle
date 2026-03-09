//
//  TransformNavigationView.swift
//  Normle
//
//  Created by Hiromu Nakano on 2025/11/23.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import NormleLibrary
import SwiftData
import SwiftUI

struct TransformNavigationView: View {
    var body: some View {
        NavigationStack {
            BaseTransformView()
                .navigationTitle("Transforms")
        }
    }
}

#Preview("Transforms - Navigation") {
    let container = PreviewData.makeContainer()
    PreviewData.seed(container: container)
    let preferencesStore = UserPreferencesStore()
    return TransformNavigationView()
        .modelContainer(container)
        .environmentObject(preferencesStore)
}
