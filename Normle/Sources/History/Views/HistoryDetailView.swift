//
//  HistoryDetailView.swift
//  Normle
//
//  Created by Hiromu Nakano on 2025/11/23.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import MHUI
import NormleLibrary
import SwiftData
import SwiftUI
import TipKit

struct HistoryDetailView: View {
    let record: TransformRecord

    var body: some View {
        List {
            sourceTextSection
            targetTextSection
            mappingsSection
            restoreSection
        }
        .mhListChrome(
            title: Text(record.date.formatted(date: .abbreviated, time: .shortened))
        )
        .task {
            markHistoryRecordOpened()
        }
    }
}

private extension HistoryDetailView {
    var sourceTextSection: some View {
        Section {
            if let sourceText = record.retainedSourceText {
                Text(sourceText)
                    .textSelection(.enabled)
                CopyButton(text: sourceText)
            } else {
                Text("Source text not retained.")
                    .mhTextStyle(.supporting, colorRole: .secondaryText)
            }
        } header: {
            Text("Source text")
                .mhSectionHeaderTitle()
                .mhSectionHeader()
        }
    }

    var targetTextSection: some View {
        Section {
            Text(record.targetText)
                .textSelection(.enabled)
            CopyButton(text: record.targetText)
        } header: {
            Text("Target text")
                .mhSectionHeaderTitle()
                .mhSectionHeader()
        }
    }

    var mappingsSection: some View {
        Section {
            if record.mappings.isEmpty {
                Text("No explicit mappings were stored. Restore falls back to source and target text.")
                    .mhTextStyle(.supporting, colorRole: .secondaryText)
            } else {
                Text(
                    String.localizedStringWithFormat(
                        String(localized: "Stored mappings: %lld"),
                        record.mappings.count
                    )
                )
                .mhTextStyle(.supporting, colorRole: .secondaryText)
            }
        } header: {
            Text("Mappings")
                .mhSectionHeaderTitle()
                .mhSectionHeader()
        }
    }

    var restoreSection: some View {
        Section {
            NavigationLink {
                RestoreView(record: record)
            } label: {
                Label("Restore with this record", systemImage: "arrow.uturn.backward")
                    .mhRow()
            }
            .popoverTip(HistoryRestoreTip())
        }
    }

    func markHistoryRecordOpened() {
        NormleTipManager.donate(NormleTipEvents.didOpenHistoryRecord)
        HistoryListTip().invalidate(reason: .actionPerformed)
    }
}

#Preview("History - Detail") {
    let container = PreviewData.makeContainer()
    let record = PreviewData.makeSampleTransformRecord(container: container)
    let assembly = NormleAppAssembly.preview(container: container)
    return assembly.previewRootView(
        NavigationStack {
            HistoryDetailView(record: record)
        }
    )
}
