//
//  MappingNavigationView.swift
//
//
//  Created by Hiromu Nakano on 2025/11/23.
//

import NormleLibrary
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
