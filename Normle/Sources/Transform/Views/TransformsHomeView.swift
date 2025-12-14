//
//  TransformsHomeView.swift
//
//
//  Created by Hiromu Nakano on 2025/11/23.
//

import SwiftUI

struct TransformsHomeView: View {
    @State private var selectedCategory: TransformCategory = .builtIn

    var body: some View {
        VStack(spacing: 12) {
            Picker("Transform category", selection: $selectedCategory) {
                ForEach(TransformCategory.allCases) { category in
                    Text(category.title).tag(category)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.top, 8)

            Group {
                switch selectedCategory {
                case .builtIn:
                    BaseTransformView()
                case .customMapping:
                    MaskView()
                }
            }
        }
        .navigationTitle("Transforms")
    }
}

private enum TransformCategory: String, CaseIterable, Identifiable {
    case builtIn
    case customMapping

    var id: Self {
        self
    }

    var title: String {
        switch self {
        case .builtIn:
            "Built-in"
        case .customMapping:
            "Custom"
        }
    }
}
