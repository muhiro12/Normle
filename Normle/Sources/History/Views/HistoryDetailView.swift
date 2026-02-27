//
//  HistoryDetailView.swift
//
//
//  Created by Hiromu Nakano on 2025/11/23.
//

import NormleLibrary
import SwiftData
import SwiftUI

struct HistoryDetailView: View {
    let record: TransformRecord

    var body: some View {
        List {
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
            Section("Target text") {
                Text(record.targetText)
                    .textSelection(.enabled)
                CopyButton(text: record.targetText)
            }

            Section("Mappings") {
                if record.mappings.isEmpty {
                    Text("No explicit mappings were stored. Restore falls back to source and target text.")
                        .foregroundStyle(.secondary)
                } else {
                    Text("Stored mappings: \(record.mappings.count)")
                        .foregroundStyle(.secondary)
                }
            }

            Section {
                NavigationLink {
                    RestoreView(record: record)
                } label: {
                    Label("Restore with this record", systemImage: "arrow.uturn.backward")
                }
            }
        }
        .navigationTitle(record.date.formatted(date: .abbreviated, time: .shortened))
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
