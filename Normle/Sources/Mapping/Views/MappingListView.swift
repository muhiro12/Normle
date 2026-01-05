//
//  MappingListView.swift
//
//
//  Created by Hiromu Nakano on 2025/11/23.
//

import NormleLibrary
import SwiftData
import SwiftUI
import UniformTypeIdentifiers

struct MappingListView: View {
    @Environment(\.modelContext)
    private var context

    @Query private var rules: [MappingRule]

    @State private var isPresentingCreate = false
    @State private var isExporting = false
    @State private var exportDocument = MappingRuleExportDocument(data: Data())
    @State private var isImporting = false
    @State private var pendingImportData: Data?
    @State private var isChoosingImportPolicy = false
    @State private var alertTitle = String()
    @State private var alertMessage = String()
    @State private var isShowingAlert = false

    init() {
        _rules = Query(
            FetchDescriptor(
                sortBy: [
                    .init(\MappingRule.date, order: .reverse)
                ]
            )
        )
    }

    var body: some View {
        List {
            ForEach(rules) { rule in
                NavigationLink(value: rule) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(rule.target.isEmpty ? String(localized: "Target not set") : rule.target)
                            .font(.headline)
                        if rule.isEnabled == false {
                            Text("Disabled")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Text(rule.source.isEmpty ? String(localized: "Source not set") : rule.source)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text(rule.date.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Mappings")
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button {
                    exportRules()
                } label: {
                    Label("Export", systemImage: "square.and.arrow.up")
                }
                Button {
                    isImporting = true
                } label: {
                    Label("Import", systemImage: "square.and.arrow.down")
                }
                Button {
                    isPresentingCreate = true
                } label: {
                    Label("Add", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $isPresentingCreate) {
            NavigationStack {
                MappingEditView(
                    rule: nil,
                    isPresented: $isPresentingCreate
                )
            }
        }
        .fileExporter(
            isPresented: $isExporting,
            document: exportDocument,
            contentType: .json,
            defaultFilename: String(localized: "mappings")
        ) { result in
            if case let .failure(error) = result {
                presentError(message: error.localizedDescription)
            }
        }
        .fileImporter(
            isPresented: $isImporting,
            allowedContentTypes: [.json]
        ) { result in
            switch result {
            case let .success(url):
                prepareImport(url: url)
            case let .failure(error):
                presentError(message: error.localizedDescription)
            }
        }
        .confirmationDialog(
            "Import mappings",
            isPresented: $isChoosingImportPolicy
        ) {
            Button("Replace all") {
                applyImport(policy: .replaceAll)
            }
            Button("Merge existing") {
                applyImport(policy: .mergeExisting)
            }
            Button("Append new") {
                applyImport(policy: .appendNew)
            }
            Button("Cancel", role: .cancel) {
                pendingImportData = nil
            }
        }
        .alert(
            alertTitle,
            isPresented: $isShowingAlert
        ) {
            Button("OK", role: .cancel) {
            }
        } message: {
            Text(alertMessage)
        }
    }
}

private extension MappingListView {
    func exportRules() {
        do {
            let data = try MappingRuleTransferService.exportData(
                context: context
            )
            exportDocument = MappingRuleExportDocument(data: data)
            isExporting = true
        } catch {
            presentError(message: error.localizedDescription)
        }
    }

    func prepareImport(url: URL) {
        do {
            pendingImportData = try Data(contentsOf: url)
            isChoosingImportPolicy = true
        } catch {
            presentError(message: error.localizedDescription)
        }
    }

    func applyImport(
        policy: MappingRuleTransferService.ImportPolicy
    ) {
        guard let data = pendingImportData else {
            return
        }
        do {
            let result = try MappingRuleTransferService.importData(
                data,
                context: context,
                policy: policy
            )
            alertTitle = String(localized: "Import completed")
            let insertedText = String.localizedStringWithFormat(
                String(localized: "Inserted: %d"),
                result.insertedCount
            )
            let updatedText = String.localizedStringWithFormat(
                String(localized: "Updated: %d"),
                result.updatedCount
            )
            let totalText = String.localizedStringWithFormat(
                String(localized: "Total: %d"),
                result.totalCount
            )
            alertMessage = [insertedText, updatedText, totalText].joined(separator: "\n")
            isShowingAlert = true
        } catch {
            presentError(message: error.localizedDescription)
        }
        pendingImportData = nil
    }

    func presentError(
        message: String
    ) {
        alertTitle = String(localized: "Error")
        alertMessage = message
        isShowingAlert = true
    }
}
