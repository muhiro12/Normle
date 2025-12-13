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

    @Query private var rules: [MaskRule]

    @State private var isPresentingCreate = false
    @State private var isExporting = false
    @State private var exportDocument = MaskRuleExportDocument(data: Data())
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
                    .init(\MaskRule.date, order: .reverse)
                ]
            )
        )
    }

    var body: some View {
        List {
            ForEach(rules) { rule in
                NavigationLink(value: rule) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(rule.masked.isEmpty ? "Masked not set" : rule.masked)
                            .font(.headline)
                        if rule.isEnabled == false {
                            Text("Disabled")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Text(rule.original.isEmpty ? "Original not set" : rule.original)
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
            defaultFilename: "mappings"
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
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
    }
}

private extension MappingListView {
    func exportRules() {
        do {
            let data = try MaskRuleTransferService.exportData(
                context: context
            )
            exportDocument = MaskRuleExportDocument(data: data)
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
        policy: MaskRuleTransferService.ImportPolicy
    ) {
        guard let data = pendingImportData else {
            return
        }
        do {
            let result = try MaskRuleTransferService.importData(
                data,
                context: context,
                policy: policy
            )
            alertTitle = "Import completed"
            alertMessage = """
            Inserted: \(result.insertedCount)
            Updated: \(result.updatedCount)
            Total: \(result.totalCount)
            """
            isShowingAlert = true
        } catch {
            presentError(message: error.localizedDescription)
        }
        pendingImportData = nil
    }

    func presentError(
        message: String
    ) {
        alertTitle = "Error"
        alertMessage = message
        isShowingAlert = true
    }
}
