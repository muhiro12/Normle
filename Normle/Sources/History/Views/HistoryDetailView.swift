//
//  HistoryDetailView.swift
//  Normle
//
//  Created by Hiromu Nakano on 2025/11/23.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import NormleLibrary
import SwiftData
import SwiftUI

struct HistoryDetailView: View {
    let record: TransformRecord

    var body: some View {
        List {
            sourceTextSection
            targetTextSection
            mappingsSection
            restoreSection
        }
        .navigationTitle(record.date.formatted(date: .abbreviated, time: .shortened))
    }
}

private extension HistoryDetailView {
    var sourceTextSection: some View {
        Section("Source text") {
            if let sourceText = record.retainedSourceText {
                Text(sourceText)
                    .textSelection(.enabled)
                CopyButton(text: sourceText)
            } else {
                Text("Source text not retained.")
                    .foregroundStyle(.secondary)
            }
        }
    }

    var targetTextSection: some View {
        Section("Target text") {
            Text(record.targetText)
                .textSelection(.enabled)
            CopyButton(text: record.targetText)
        }
    }

    var mappingsSection: some View {
        Section("Mappings") {
            if record.mappings.isEmpty {
                Text("No explicit mappings were stored. Restore falls back to source and target text.")
                    .foregroundStyle(.secondary)
            } else {
                Text("Stored mappings: \(record.mappings.count)")
                    .foregroundStyle(.secondary)
            }
        }
    }

    var restoreSection: some View {
        Section {
            NavigationLink {
                RestoreView(record: record)
            } label: {
                Label("Restore with this record", systemImage: "arrow.uturn.backward")
            }
        }
    }
}

#Preview("History - Detail") {
    let container = PreviewData.makeContainer()
    let record = PreviewData.makeSampleTransformRecord(container: container)
    return NavigationStack {
        HistoryDetailView(record: record)
    }
    .modelContainer(container)
}
