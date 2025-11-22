//
//  MaskView.swift
//
//
//  Created by Hiromu Nakano on 2025/11/23.
//

import MaskleLibrary
import SwiftData
import SwiftUI

struct MaskView: View {
    @Environment(\.modelContext)
    private var context
    @Environment(SettingsStore.self)
    private var settingsStore

    @Query private var manualRules: [ManualRule]

    @State private var viewModel = MaskViewModel()
    @State private var isHistorySavedMessagePresented = false

    init() {
        _manualRules = Query(
            FetchDescriptor(
                sortBy: [
                    .init(\ManualRule.createdAt, order: .reverse)
                ]
            )
        )
    }

    var body: some View {
        List {
            Section("Original text") {
                TextEditor(text: $viewModel.sourceText)
                    .frame(minHeight: 200)
            }

            let mappingCount = manualRules.count
            if mappingCount > .zero {
                Section("Manual mappings") {
                    HStack {
                        Text("Mappings")
                        Spacer()
                        Text("\(mappingCount)")
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Section("Note") {
                TextField(
                    "Optional memo for this session",
                    text: $viewModel.note
                )
            }

            Section {
                Button {
                    viewModel.anonymize(
                        context: context,
                        settingsStore: settingsStore,
                        manualRules: manualRules.map(\.maskingRule)
                    )
                    isHistorySavedMessagePresented = settingsStore.isHistoryAutoSaveEnabled
                } label: {
                    Label("Anonymize", systemImage: "wand.and.stars")
                }
                .disabled(viewModel.sourceText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }

            if let result = viewModel.result {
                summarySection(
                    result: result,
                    session: viewModel.lastSavedSession
                )
                maskedOutputSection(result: result)
            }
        }
        .navigationTitle("Mask")
        .alert("Saved to history", isPresented: $isHistorySavedMessagePresented) {
            Button("OK") {
            }
        } message: {
            Text("You can review this session anytime from History.")
        }
    }
}

private extension MaskView {
    @ViewBuilder
    func summarySection(
        result: MaskingResult,
        session: MaskingSession?
    ) -> some View {
        Section("Latest result") {
            HStack {
                Text("Processed at")
                Spacer()
                Text((session?.createdAt ?? Date()).formatted(date: .abbreviated, time: .shortened))
                    .foregroundStyle(.secondary)
            }
            HStack {
                Text("Mappings")
                Spacer()
                Text("\(result.mappings.count)")
                    .foregroundStyle(.secondary)
            }
            if let note = session?.note?.trimmingCharacters(in: .whitespacesAndNewlines), note.isEmpty == false {
                HStack {
                    Text("Memo")
                    Spacer()
                    Text(note)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    @ViewBuilder
    func maskedOutputSection(
        result: MaskingResult
    ) -> some View {
        Section("Masked text") {
            TextEditor(text: .constant(result.maskedText))
                .frame(minHeight: 180)
                .textSelection(.enabled)
            CopyButton(text: result.maskedText)
        }
    }
}
