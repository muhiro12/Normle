//
//  StoreLicensesView.swift
//  Normle
//
//  Created by Codex on 2026/03/10.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import MHPlatform
import SwiftUI

struct StoreLicensesView: View {
    @Environment(MHAppRuntime.self)
    private var runtime

    var body: some View {
        runtime.licensesView()
            .navigationTitle("Licenses")
    }
}

#Preview("Store - Licenses") {
    let assembly = NormleAppAssembly.preview()

    return assembly.previewRootView(
        NavigationStack {
            StoreLicensesView()
        }
    )
}
