//
//  MappingListView.swift
//  Normle
//
//  Created by Hiromu Nakano on 2025/11/23.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import NormleLibrary
import SwiftData
import SwiftUI
import TipKit
import UniformTypeIdentifiers

struct MappingListView: View {
    private enum Layout {
        static let listRowSpacing = 8.0
        static let horizontalPadding = 16.0
        static let compactInset = 16.0
        static let wideInset = 24.0
        static let rowSpacing = 8.0
        static let secondaryLineLimit = 2
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
        .navigationTitle("Mappings")
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
            .listRowInsets(emptyStateRowInsets)
        } else {
            ForEach(rules) { rule in
                ruleRow(rule)
            }
        }
    }

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

    func ruleRow(_ rule: MappingRule) -> some View {
        NavigationLink(value: rule) {
            VStack(alignment: .leading, spacing: Layout.rowSpacing) {
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
                    .lineLimit(Layout.secondaryLineLimit)
                Text(rule.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .listRowInsets(listRowInsets)
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
