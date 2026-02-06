//
//  HistoryListView.swift
//
//
//  Created by Hiromu Nakano on 2025/11/23.
//

import NormleLibrary
import SwiftData
import SwiftUI

struct HistoryListView: View {
    @Environment(\.modelContext)
    private var context

    @Query private var records: [TransformRecord]

    @State private var isDeleteDialogPresented = false

    private var selection: Binding<TransformRecord?>

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

    var body: some View {
        List(selection: selection) {
            if records.isEmpty {
                ContentUnavailableView(
                    "No History",
                    systemImage: "clock.arrow.circlepath",
                    description: Text("Run a transform to see it here.")
                )
                .listRowInsets(emptyStateRowInsets)
            } else {
                ForEach(records) { record in
                    NavigationLink(value: record) {
                        HistoryRowView(record: record)
                    }
                    .listRowInsets(listRowInsets)
                    .swipeActions {
                        Button(role: .destructive) {
                            delete(record: record)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
                .onDelete { offsets in
                    offsets.map { records[$0] }.forEach(delete(record:))
                }
            }
        }
        .navigationTitle("History")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        .listRowSpacing(8)
        #endif
        #if os(macOS)
        .listStyle(.inset)
        .padding(.horizontal, 16)
        #else
        .listStyle(.insetGrouped)
        #endif
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
                HistoryDeletionService.deleteAll(context: context)
            } label: {
                Text("Delete")
            }
            Button(role: .cancel) {
            } label: {
                Text("Cancel")
            }
        }
    }
}

private extension HistoryListView {
    var listRowInsets: EdgeInsets {
        #if os(macOS)
        return .init(top: 16, leading: 24, bottom: 16, trailing: 24)
        #else
        return .init(top: 16, leading: 16, bottom: 16, trailing: 16)
        #endif
    }

    var emptyStateRowInsets: EdgeInsets {
        #if os(macOS)
        return .init(top: 24, leading: 24, bottom: 24, trailing: 24)
        #else
        return .init(top: 24, leading: 16, bottom: 24, trailing: 16)
        #endif
    }

    func delete(
        record: TransformRecord
    ) {
        HistoryDeletionService.delete(
            record: record,
            context: context
        )
    }
}

#Preview("History - List") {
    let container = PreviewData.makeContainer()
    PreviewData.seed(container: container)
    return NavigationStack {
        HistoryListView()
    }
    .modelContainer(container)
}

#Preview("History - Large Type") {
    let container = PreviewData.makeContainer()
    PreviewData.seed(container: container)
    return NavigationStack {
        HistoryListView()
    }
    .modelContainer(container)
    .environment(\.dynamicTypeSize, .accessibility3)
}
