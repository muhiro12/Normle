//
//  HistoryDetailView.swift
//
//
//  Created by Hiromu Nakano on 2025/11/23.
//

import NormleLibrary
import SwiftUI

struct HistoryDetailView: View {
    let record: TransformRecord

    var body: some View {
        List {
            Section("Target text") {
                Text(record.targetText)
                    .textSelection(.enabled)
                CopyButton(text: record.targetText)
            }

            Section("Mappings") {
                Text("Mappings are not retained in history.")
                    .foregroundStyle(.secondary)
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
