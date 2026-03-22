//
//  HistoryRowView.swift
//  Normle
//
//  Created by Hiromu Nakano on 2025/11/23.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import MHUI
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
            Text(record.date.formatted(date: .abbreviated, time: .shortened))
                .mhRowOverline()
            Text(record.previewText)
                .mhRowTitle()
                .lineLimit(Layout.previewLineLimit)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .mhRow()
    }
}

#Preview("History - Row") {
    let container = PreviewData.makeContainer()
    let record = PreviewData.makeSampleTransformRecord(container: container)
    let assembly = NormleAppAssembly.preview(container: container)
    return assembly.previewRootView(
        HistoryRowView(record: record)
            .padding()
    )
}
