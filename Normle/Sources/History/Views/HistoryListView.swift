//
//  HistoryListView.swift
//  Normle
//
//  Created by Hiromu Nakano on 2025/11/23.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import NormleLibrary
import SwiftData
import SwiftUI
import TipKit

struct HistoryListView: View {
    private enum Layout {
        static let listRowSpacing = 8.0
        static let horizontalPadding = 16.0
        static let compactInset = 16.0
        static let wideInset = 24.0
        static let iOSRowInsets = EdgeInsets(
            top: compactInset,
            leading: compactInset,
            bottom: compactInset,
            trailing: compactInset
        )
        static let macOSRowInsets = EdgeInsets(
            top: compactInset,
            leading: wideInset,
            bottom: compactInset,
            trailing: wideInset
        )
        static let iOSEmptyStateInsets = EdgeInsets(
            top: wideInset,
            leading: compactInset,
            bottom: wideInset,
            trailing: compactInset
        )
        static let macOSEmptyStateInsets = EdgeInsets(
            top: wideInset,
            leading: wideInset,
            bottom: wideInset,
            trailing: wideInset
        )
    }

    @Environment(\.modelContext)
    private var context

    @Query private var records: [TransformRecord]

    @State private var isDeleteDialogPresented = false

    private var selection: Binding<TransformRecord?>

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
                TipView(HistoryListTip())
                    .tipViewStyle(.miniTip)
                    .listRowInsets(listRowInsets)

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
        .listRowSpacing(Layout.listRowSpacing)
        #endif
        #if os(macOS)
        .listStyle(.inset)
        .padding(.horizontal, Layout.horizontalPadding)
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
                deleteAll()
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
    var listRowInsets: EdgeInsets {
        #if os(macOS)
        return Layout.macOSRowInsets
        #else
        return Layout.iOSRowInsets
        #endif
    }

    var emptyStateRowInsets: EdgeInsets {
        #if os(macOS)
        return Layout.macOSEmptyStateInsets
        #else
        return Layout.iOSEmptyStateInsets
        #endif
    }

    func delete(
        record: TransformRecord
    ) {
        do {
            try TransformRecordService.delete(
                context: context,
                record: record
            )
        } catch {
            assertionFailure(error.localizedDescription)
        }
    }

    func deleteAll() {
        do {
            try TransformRecordService.deleteAll(
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
