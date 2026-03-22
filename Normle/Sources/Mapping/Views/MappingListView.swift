//
//  MappingListView.swift
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
import UniformTypeIdentifiers

struct MappingListView: View {
    private enum Layout {
        static let rowSpacing = 8.0
        static let secondaryLineLimit = 2
    }

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

    var body: some View {
        List {
            rulesContent
        }
        .mhListChrome(title: "Mappings")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    presentCreate()
                } label: {
                    Label("Add", systemImage: "plus")
                }
                .popoverTip(rules.isEmpty ? MappingAddTip() : nil)
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
                isShowingAlert = false
            }
        } message: {
            Text(alertMessage)
        }
    }

    init() {
        _rules = Query(
            FetchDescriptor(
                sortBy: [
                    .init(\MappingRule.date, order: .reverse)
                ]
            )
        )
    }
}

private extension MappingListView {
    @ViewBuilder var rulesContent: some View {
        if rules.isEmpty {
            ContentUnavailableView(
                "No Mappings",
                systemImage: "link",
                description: Text("Create a mapping to get started.")
            )
            .mhEmptyStateLayout()
            .mhSurfaceInset()
            .mhSurface()
        } else {
            ForEach(rules) { rule in
                ruleRow(rule)
            }
        }
    }

    func ruleRow(_ rule: MappingRule) -> some View {
        NavigationLink(value: rule) {
            VStack(alignment: .leading, spacing: Layout.rowSpacing) {
                Text(rule.date.formatted(date: .abbreviated, time: .shortened))
                    .mhRowOverline()
                HStack(alignment: .firstTextBaseline, spacing: Layout.rowSpacing) {
                    Text(rule.target.isEmpty ? String(localized: "Target not set") : rule.target)
                        .mhRowTitle()
                        .lineLimit(1)
                    if rule.isEnabled == false {
                        Text("Disabled")
                            .mhBadge()
                    }
                }
                Text(rule.source.isEmpty ? String(localized: "Source not set") : rule.source)
                    .mhRowSupporting()
                    .lineLimit(Layout.secondaryLineLimit)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .mhRow()
        }
    }

    func presentCreate() {
        NormleTipManager.donate(NormleTipEvents.didStartMappingCreation)
        MappingAddTip().invalidate(reason: .actionPerformed)
        isPresentingCreate = true
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

        Task {
            await applyImport(
                data: data,
                policy: policy
            )
        }
    }

    @MainActor
    func applyImport(
        data: Data,
        policy: MappingRuleTransferService.ImportPolicy
    ) async {
        defer {
            pendingImportData = nil
        }

        do {
            let result = try await NormleMutationWorkflow.importMappings(
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
    let assembly = NormleAppAssembly.preview(container: container)
    return assembly.previewRootView(
        NavigationStack {
            MappingListView()
        }
    )
}

#Preview("Mappings - Dark") {
    let container = PreviewData.makeContainer()
    PreviewData.seed(container: container)
    let assembly = NormleAppAssembly.preview(container: container)
    return assembly.previewRootView(
        NavigationStack {
            MappingListView()
        }
    )
    .environment(\.colorScheme, .dark)
}
