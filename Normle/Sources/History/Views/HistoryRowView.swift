//
//  HistoryRowView.swift
//  Normle
//
//  Created by Hiromu Nakano on 2025/11/23.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import NormleLibrary
import SwiftData
import SwiftUI

struct HistoryRowView: View {
    private enum Layout {
        static let spacing = 4.0
        static let previewLineLimit = 2
    }

    let record: TransformRecord

    var body: some View {
        VStack(alignment: .leading, spacing: Layout.spacing) {
            HStack {
                Text(record.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.headline)
                Spacer()
            }
            Text(record.previewText)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(Layout.previewLineLimit)
        }
    }
}

#Preview("History - Row") {
    let container = PreviewData.makeContainer()
    let record = PreviewData.makeSampleTransformRecord(container: container)
    return HistoryRowView(record: record)
        .padding()
        .modelContainer(container)
}
