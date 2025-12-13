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

    @Query private var records: [MaskRecord]

    @State private var isDeleteDialogPresented = false

    private var selection: Binding<MaskRecord?>

    init(
        selection: Binding<MaskRecord?> = .constant(nil)
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
            ForEach(records) { record in
                NavigationLink(value: record) {
                    HistoryRowView(record: record)
                }
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
        .navigationTitle("History")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(role: .destructive) {
                    isDeleteDialogPresented = true
                } label: {
                    Label("Delete All", systemImage: "trash")
                }
                .disabled(records.isEmpty)
            }
        }
        .confirmationDialog(
            "Delete all records?",
            isPresented: $isDeleteDialogPresented
        ) {
            Button(role: .destructive) {
                do {
                    try MaskRecordService.deleteAll(context: context)
                } catch {
                    assertionFailure(error.localizedDescription)
                }
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
    func delete(
        record: MaskRecord
    ) {
        do {
            try MaskRecordService.delete(
                context: context,
                record: record
            )
        } catch {
            assertionFailure(error.localizedDescription)
        }
    }
}
