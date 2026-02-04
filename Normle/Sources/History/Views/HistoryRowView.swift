//
//  HistoryRowView.swift
//
//
//  Created by Hiromu Nakano on 2025/11/23.
//

import NormleLibrary
import SwiftData
import SwiftUI

struct HistoryRowView: View {
    let record: TransformRecord

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(record.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.headline)
                Spacer()
            }
            Text(record.previewText)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)
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
