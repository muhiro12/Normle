//
//  StoreNavigationView.swift
//  Normle
//
//  Created by Hiromu Nakano on 2025/11/23.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct StoreNavigationView: View {
    var body: some View {
        StoreListView()
    }
}

#Preview("Store - Navigation") {
    let assembly = NormleAppAssembly.preview()

    return assembly.previewRootView(StoreNavigationView())
}
