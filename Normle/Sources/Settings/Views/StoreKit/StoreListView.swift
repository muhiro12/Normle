//
//  StoreListView.swift
//  Normle
//
//  Created by Hiromu Nakano on 2025/11/23.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct StoreListView: View {
    var body: some View {
        List {
            StoreSection()
            NavigationLink(value: NormleSettingsDestination.licenses) {
                Label("Licenses", systemImage: "doc.text")
            }
        }
        .navigationTitle("Subscription")
    }
}

#Preview("Store - List") {
    let assembly = NormleAppAssembly.preview()

    return assembly.previewRootView(
        NavigationStack {
            StoreListView()
                .navigationDestination(for: NormleSettingsDestination.self) { destination in
                    switch destination {
                    case .subscription:
                        StoreListView()
                    case .licenses:
                        StoreLicensesView()
                    }
                }
        }
    )
}
