//
//  StoreSection.swift
//
//
//  Created by Hiromu Nakano on 2025/11/23.
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
