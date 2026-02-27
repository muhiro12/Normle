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
            if rules.isEmpty {
                ContentUnavailableView(
                    "No Mappings",
                    systemImage: "link",
                    description: Text("Create a mapping to get started.")
                )
                .listRowInsets(emptyStateRowInsets)
            } else {
                ForEach(rules) { rule in
                    NavigationLink(value: rule) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(rule.target.isEmpty ? String(localized: "Target not set") : rule.target)
                                .font(.headline)
                                .lineLimit(1)
                            if rule.isEnabled == false {
                                Text("Disabled")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Text(rule.source.isEmpty ? String(localized: "Source not set") : rule.source)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                            Text(rule.date.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .listRowInsets(listRowInsets)
                }
            }
        }
        .navigationTitle("Mappings")
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
                Button {
                    isPresentingCreate = true
                } label: {
                    Label("Add", systemImage: "plus")
                }
            }
            ToolbarItem(placement: .primaryAction) {
                Menu {
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
                } label: {
                    Label("More", systemImage: "ellipsis.circle")
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

    func exportRules() {
        do {
            let data = try MappingRuleTransferCoordinator.exportData(
                context: context
            )
            exportDocument = .init(data: data)
            isExporting = true
        } catch {
            presentError(message: error.localizedDescription)
        }
    }

    func prepareImport(url: URL) {
        do {
            pendingImportData = try MappingRuleTransferCoordinator.loadImportData(
                from: url
            )
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
            let result = try MappingRuleTransferCoordinator.applyImport(
                data: data,
                context: context,
                policy: policy
            )
            alertTitle = String(localized: "Import completed")
            let lines = result.summaryLines(
                insertedText: { count in
                    String.localizedStringWithFormat(
                        String(localized: "Inserted: %d"),
                        count
                    )
                },
                updatedText: { count in
                    String.localizedStringWithFormat(
                        String(localized: "Updated: %d"),
                        count
                    )
                },
                totalText: { count in
                    String.localizedStringWithFormat(
                        String(localized: "Total: %d"),
                        count
                    )
                }
            )
            alertMessage = lines.joined(separator: "\n")
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

#Preview("Mappings - List") {
    let container = PreviewData.makeContainer()
    PreviewData.seed(container: container)
    return NavigationStack {
        MappingListView()
    }
    .modelContainer(container)
}

#Preview("Mappings - Dark") {
    let container = PreviewData.makeContainer()
    PreviewData.seed(container: container)
    return NavigationStack {
        MappingListView()
    }
    .modelContainer(container)
    .environment(\.colorScheme, .dark)
}
