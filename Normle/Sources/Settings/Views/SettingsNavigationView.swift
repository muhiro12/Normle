//
//  SettingsNavigationView.swift
//  Normle
//
//  Created by Hiromu Nakano on 2025/11/23.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import SwiftData
import SwiftUI

struct SettingsNavigationView: View {
    @Binding var path: NavigationPath

    var body: some View {
        NavigationStack(path: $path) {
            SettingsListView()
                .navigationDestination(for: NormleSettingsDestination.self) { destination in
                    switch destination {
                    case .subscription:
                        StoreListView()
                    case .licenses:
                        StoreLicensesView()
                    }
                }
        }
    }
}

#Preview("Settings - Navigation") {
    let container = PreviewData.makeContainer()
    let assembly = NormleAppAssembly.preview(container: container)
    return assembly.previewRootView(
        SettingsNavigationView(
            path: .constant(.init())
        )
    )
    .modelContainer(container)
}
