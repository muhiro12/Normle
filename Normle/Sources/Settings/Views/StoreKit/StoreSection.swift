//
//  StoreSection.swift
//  Normle
//
//  Created by Hiromu Nakano on 2025/11/23.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import MHAppRuntimeCore
import SwiftUI

struct StoreSection: View {
    @Environment(MHAppRuntime.self)
    private var runtime

    var body: some View {
        runtime.subscriptionSectionView()
    }
}

#Preview("Store - Section") {
    let assembly = NormleAppAssembly.preview()

    return assembly.previewRootView(
        List {
            StoreSection()
        }
    )
}
