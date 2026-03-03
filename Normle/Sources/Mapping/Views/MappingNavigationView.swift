//
//  MappingNavigationView.swift
//  Normle
//
//  Created by Hiromu Nakano on 2025/11/23.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import NormleLibrary
import SwiftData
import SwiftUI

struct MappingNavigationView: View {
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            MappingListView()
                .navigationDestination(for: MappingRule.self) { rule in
                    MappingDetailView(rule: rule)
                }
        }
    }
}

#Preview("Mapping - Navigation") {
    let container = PreviewData.makeContainer()
    PreviewData.seed(container: container)
    return MappingNavigationView()
        .modelContainer(container)
}
