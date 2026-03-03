//
//  StoreSection.swift
//  Normle
//
//  Created by Hiromu Nakano on 2025/11/23.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import StoreKitWrapper
import SwiftUI

struct StoreSection: View {
    @Environment(Store.self)
    private var store

    var body: some View {
        store.buildSubscriptionSection()
    }
}

#Preview("Store - Section") {
    List {
        StoreSection()
    }
    .environment(Store())
}
