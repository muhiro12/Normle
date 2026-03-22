//
//  MappingDetailView.swift
//  Normle
//
//  Created by Hiromu Nakano on 2025/11/23.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import MHUI
import NormleLibrary
import SwiftData
import SwiftUI

struct MappingDetailView: View {
    let rule: MappingRule

    @State private var isEditing = false

    var body: some View {
        List {
            detailsSection
            actionSection
        }
        .mhListChrome(title: "Mapping Detail")
        .sheet(isPresented: $isEditing) {
            NavigationStack {
                MappingEditView(
                    rule: rule,
                    isPresented: $isEditing
                )
            }
        }
    }
}

private extension MappingDetailView {
    var detailsSection: some View {
        Section {
            LabeledContent("Target") {
                Text(rule.target.isEmpty ? String(localized: "Not set") : rule.target)
            }
            .labeledContentStyle(.mhKeyValue)

            LabeledContent("Source") {
                Text(rule.source.isEmpty ? String(localized: "Not set") : rule.source)
            }
            .labeledContentStyle(.mhKeyValue)

            LabeledContent("Kind") {
                Text("Tags are not set")
            }
            .labeledContentStyle(.mhKeyValue)

            LabeledContent("Status") {
                Text(rule.isEnabled ? String(localized: "Enabled") : String(localized: "Disabled"))
                    .mhBadge(style: rule.isEnabled ? .positive : .neutral)
            }
            .labeledContentStyle(.mhKeyValue)

            LabeledContent("Created at") {
                Text(rule.date.formatted(date: .abbreviated, time: .shortened))
            }
            .labeledContentStyle(.mhKeyValue)
        } header: {
            Text("Details")
                .mhSectionHeaderTitle()
                .mhSectionHeader()
        }
    }

    var actionSection: some View {
        Section {
            Button("Edit") {
                isEditing = true
            }
            .buttonStyle(.mhPrimary)
        }
    }
}

#Preview("Mapping - Detail") {
    let container = PreviewData.makeContainer()
    let rule = PreviewData.makeSampleMappingRule(container: container)
    let assembly = NormleAppAssembly.preview(container: container)
    return assembly.previewRootView(
        NavigationStack {
            MappingDetailView(rule: rule)
        }
    )
}
