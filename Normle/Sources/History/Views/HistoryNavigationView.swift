//
//  HistoryNavigationView.swift
//  Normle
//
//  Created by Hiromu Nakano on 2025/11/23.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import NormleLibrary
import SwiftData
import SwiftUI

struct HistoryNavigationView: View {
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            HistoryListView()
                .navigationDestination(for: TransformRecord.self) { record in
                    HistoryDetailView(record: record)
                }
        }
    }
}

#Preview("History - Navigation") {
    let container = PreviewData.makeContainer()
    PreviewData.seed(container: container)
    return HistoryNavigationView()
        .modelContainer(container)
}
