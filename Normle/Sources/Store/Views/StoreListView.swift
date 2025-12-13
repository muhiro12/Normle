//
//  StoreListView.swift
//
//
//  Created by Hiromu Nakano on 2025/11/23.
//

import SwiftUI

struct StoreListView: View {
    var body: some View {
        List {
            StoreSection()
        }
        .navigationTitle("Subscription")
    }
}
