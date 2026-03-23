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

    @State private var screenModel = MappingListScreenModel()
    @State private var isPresentingCreate = false
    @State private var isExporting = false
    @State private var isImporting = false
    @State private var isChoosingImportPolicy = false

    var body: some View {
        List {
            rulesContent
        }
        .mhListChrome(title: "Mappings")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    screenModel.presentCreate()
                    isPresentingCreate = true
                } label: {
                    Label("Add", systemImage: "plus")
                }
                .popoverTip(rules.isEmpty ? MappingAddTip() : nil)
            }
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button {
                        if screenModel.prepareExport(
                            context: context
                        ) {
                            isExporting = true
                        }
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
            document: screenModel.exportDocument,
            contentType: .json,
            defaultFilename: String(localized: "mappings")
        ) { result in
            if case let .failure(error) = result {
                screenModel.presentError(
                    message: error.localizedDescription
                )
            }
        }
        .fileImporter(
            isPresented: $isImporting,
            allowedContentTypes: [.json]
        ) { result in
            switch result {
            case let .success(url):
                if screenModel.prepareImport(url: url) {
                    isChoosingImportPolicy = true
                }
            case let .failure(error):
                screenModel.presentError(
                    message: error.localizedDescription
                )
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
                screenModel.clearPendingImportData()
            }
        }
        .alert(
            screenModel.alertTitle,
            isPresented: Binding(
                get: {
                    screenModel.isShowingAlert
                },
                set: { isPresented in
                    if isPresented == false {
                        screenModel.dismissAlert()
                    }
                }
            )
        ) {
            Button("OK", role: .cancel) {
                screenModel.dismissAlert()
            }
        } message: {
            Text(screenModel.alertMessage)
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

    func applyImport(
        policy: MappingRuleTransferService.ImportPolicy
    ) {
        Task {
            await screenModel.applyImport(
                policy: policy,
                context: context
            )
        }
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
