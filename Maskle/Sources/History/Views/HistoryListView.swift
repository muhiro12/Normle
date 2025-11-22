//
//  HistoryListView.swift
//
//
//  Created by Hiromu Nakano on 2025/11/23.
//

import MaskleLibrary
import SwiftData
import SwiftUI

struct HistoryListView: View {
    @Environment(\.modelContext)
    private var context

    @Query private var sessions: [MaskingSession]

    @State private var isDeleteDialogPresented = false

    private var selection: Binding<MaskingSession?>

    init(
        selection: Binding<MaskingSession?> = .constant(nil)
    ) {
        self.selection = selection
        _sessions = Query(
            FetchDescriptor(
                sortBy: [
                    .init(\.createdAt, order: .reverse)
                ]
            )
        )
    }

    var body: some View {
        List(selection: selection) {
            ForEach(sessions) { session in
                NavigationLink(value: session) {
                    HistoryRowView(session: session)
                }
                .swipeActions {
                    Button(role: .destructive) {
                        delete(session: session)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
            .onDelete { offsets in
                offsets.map { sessions[$0] }.forEach(delete(session:))
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
                .disabled(sessions.isEmpty)
            }
        }
        .confirmationDialog(
            "Delete all sessions?",
            isPresented: $isDeleteDialogPresented
        ) {
            Button(role: .destructive) {
                do {
                    try SessionService.deleteAll(context: context)
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
        session: MaskingSession
    ) {
        do {
            try SessionService.delete(
                context: context,
                session: session
            )
        } catch {
            assertionFailure(error.localizedDescription)
        }
    }
}
