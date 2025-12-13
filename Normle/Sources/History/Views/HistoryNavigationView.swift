//
//  HistoryNavigationView.swift
//
//
//  Created by Hiromu Nakano on 2025/11/23.
//

import NormleLibrary
import SwiftUI

struct HistoryNavigationView: View {
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            HistoryListView()
                .navigationDestination(for: MaskRecord.self) { record in
                    HistoryDetailView(record: record)
                }
        }
    }
}
