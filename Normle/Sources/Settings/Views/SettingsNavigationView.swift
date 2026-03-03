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
    var body: some View {
        NavigationStack {
            SettingsView()
        }
    }
}

#Preview("Settings - Navigation") {
    let container = PreviewData.makeContainer()
    return SettingsNavigationView()
        .modelContainer(container)
}
