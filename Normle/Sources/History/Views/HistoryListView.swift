//
//  HistoryListView.swift
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

struct HistoryListView: View {
    @Environment(\.modelContext)
    private var context

    @Query private var records: [TransformRecord]

    @State private var isDeleteDialogPresented = false

    private var selection: Binding<TransformRecord?>

    var body: some View {
        List(selection: selection) {
            historyContent
        }
        .mhListChrome(title: "History")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button(role: .destructive) {
                        isDeleteDialogPresented = true
                    } label: {
                        Label("Delete All", systemImage: "trash")
                    }
                    .disabled(records.isEmpty)
                } label: {
                    Label("More", systemImage: "ellipsis.circle")
                }
            }
        }
        .confirmationDialog(
            "Delete all records?",
            isPresented: $isDeleteDialogPresented
        ) {
            Button(role: .destructive) {
                Task {
                    await deleteAll()
                }
            } label: {
                Text("Delete")
            }
            Button(role: .cancel) {
                isDeleteDialogPresented = false
            } label: {
                Text("Cancel")
            }
        }
    }

    init(
        selection: Binding<TransformRecord?> = .constant(nil)
    ) {
        self.selection = selection
        _records = Query(
            FetchDescriptor(
                sortBy: [
                    .init(\.date, order: .reverse)
                ]
            )
        )
    }
}

private extension HistoryListView {
    @ViewBuilder var historyContent: some View {
        if records.isEmpty {
            ContentUnavailableView(
                "No History",
                systemImage: "clock.arrow.circlepath",
                description: Text("Run a transform to see it here.")
            )
            .mhEmptyStateLayout()
            .mhSurfaceInset()
            .mhSurface()
        } else {
            TipView(HistoryListTip())
                .tipViewStyle(.miniTip)

            ForEach(records) { record in
                historyRow(record: record)
            }
            .onDelete(perform: deleteRecords)
        }
    }

    func historyRow(record: TransformRecord) -> some View {
        NavigationLink(value: record) {
            HistoryRowView(record: record)
        }
        .swipeActions {
            Button(role: .destructive) {
                Task {
                    await delete(record: record)
                }
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }

    func deleteRecords(at offsets: IndexSet) {
        let targets = offsets.map { records[$0] }
        Task {
            for record in targets {
                await delete(record: record)
            }
        }
    }

    @MainActor
    func delete(
        record: TransformRecord
    ) async {
        do {
            try await NormleMutationWorkflow.deleteHistory(
                context: context,
                record: record
            )
        } catch {
            assertionFailure(error.localizedDescription)
        }
    }

    @MainActor
    func deleteAll() async {
        do {
            try await NormleMutationWorkflow.deleteAllHistory(
                context: context
            )
        } catch {
            assertionFailure(error.localizedDescription)
        }
    }
}

#Preview("History - List") {
    let container = PreviewData.makeContainer()
    PreviewData.seed(container: container)
    let assembly = NormleAppAssembly.preview(container: container)
    return assembly.previewRootView(
        NavigationStack {
            HistoryListView()
        }
    )
}

#Preview("History - Large Type") {
    let container = PreviewData.makeContainer()
    PreviewData.seed(container: container)
    let assembly = NormleAppAssembly.preview(container: container)
    return assembly.previewRootView(
        NavigationStack {
            HistoryListView()
        }
    )
    .environment(\.dynamicTypeSize, .accessibility3)
}
