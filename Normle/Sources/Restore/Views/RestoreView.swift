//
//  RestoreView.swift
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

struct RestoreView: View {
    private enum Layout {
        static let editorMinimumHeight = 200.0
    }

    let record: TransformRecord

    @State private var viewModel = RestoreViewModel()

    var body: some View {
        List {
            sourceSection
            restoreSection
            restoredTextSection
        }
        .mhListChrome(title: "Restore")
        .task {
            markRestoreOpened()
        }
    }
}

private extension RestoreView {
    var sourceSection: some View {
        Section {
            TextEditor(text: $viewModel.sourceText)
                .frame(minHeight: Layout.editorMinimumHeight)
                .scrollContentBackground(.hidden)
                .mhInputChrome()
        } header: {
            Text("AI response to restore")
                .mhSectionHeaderTitle()
                .mhSectionHeader()
        }
    }

    var restoreSection: some View {
        Section {
            Button {
                viewModel.restore(with: record)
            } label: {
                Label("Restore", systemImage: "arrow.uturn.backward")
            }
            .disabled(viewModel.sourceText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .buttonStyle(.mhPrimary)
        }
    }

    @ViewBuilder var restoredTextSection: some View {
        if viewModel.restoredText.isEmpty == false {
            Section {
                TextEditor(text: .constant(viewModel.restoredText))
                    .frame(minHeight: Layout.editorMinimumHeight)
                    .scrollContentBackground(.hidden)
                    .textSelection(.enabled)
                    .mhInputChrome()
                CopyButton(text: viewModel.restoredText)
            } header: {
                Text("Restored text")
                    .mhSectionHeaderTitle()
                    .mhSectionHeader()
            }
        }
    }

    func markRestoreOpened() {
        NormleTipManager.donate(NormleTipEvents.didOpenRestoreView)
        HistoryRestoreTip().invalidate(reason: .actionPerformed)
    }
}

#Preview("Restore - Base") {
    let container = PreviewData.makeContainer()
    let record = PreviewData.makeSampleTransformRecord(container: container)
    let assembly = NormleAppAssembly.preview(container: container)
    return assembly.previewRootView(
        NavigationStack {
            RestoreView(record: record)
        }
    )
}
