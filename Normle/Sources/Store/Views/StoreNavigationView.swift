//
//  StoreNavigationView.swift
//
//
//  Created by Hiromu Nakano on 2025/11/23.
//

import StoreKitWrapper
import SwiftUI

struct StoreNavigationView: View {
    var body: some View {
        NavigationStack {
            StoreListView()
        }
    }
}

#Preview("Store - Navigation") {
    StoreNavigationView()
        .environment(Store())
}
