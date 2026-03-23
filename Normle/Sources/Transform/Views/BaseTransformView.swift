//
//  BaseTransformView.swift
//  Normle
//
//  Created by Hiromu Nakano on 2025/11/23.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import MHUI
import NormleLibrary
import Observation
import SwiftData
import SwiftUI
import TipKit
import UniformTypeIdentifiers

struct BaseTransformView: View {
    @Environment(\.modelContext)
    private var context
    @EnvironmentObject private var preferencesStore: UserPreferencesStore

    @Query private var mappingRules: [MappingRule]

    @State private var screenModel = BaseTransformScreenModel()
    @State private var isImporterPresented = false
    @State private var isPresetSelectorPresented = false
    @State private var isPresentingMappingCreation = false

    var body: some View {
        @Bindable var screenModel = screenModel

        Form {
            inputSection
            resultSection
            actionSection
        }
        .mhFormChrome(title: "Transforms")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    openPresetSelector()
                } label: {
                    Label("Presets", systemImage: "slider.horizontal.3")
                }
                .popoverTip(TransformPresetTip())
            }
        }
        .sheet(isPresented: $isPresetSelectorPresented) {
            presetSelectionSheet
        }
        .sheet(isPresented: $isPresentingMappingCreation) {
            mappingCreationSheet
        }
        .task {
            screenModel.applyPresetSelection(
                preferencesStore.preferences.presetSelection
            )
        }
        .onChange(of: preferencesStore.preferences) { _, newValue in
            screenModel.applyPresetSelection(
                newValue.presetSelection
            )
        }
        .alert(
            "Transform failed",
            isPresented: Binding(
                get: { screenModel.alertMessage != nil },
                set: { isPresented in
                    if isPresented == false {
                        screenModel.dismissAlert()
                    }
                }
            ),
            presenting: screenModel.alertMessage
        ) { _ in
            Button("OK", role: .cancel) {
                screenModel.dismissAlert()
            }
        } message: { message in
            Text(message)
        }
        .fileImporter(
            isPresented: $isImporterPresented,
            allowedContentTypes: [.image]
        ) { result in
            screenModel.handleImageImport(result)
        }
    }
}

private extension BaseTransformView {
    var presetSelectionSheet: some View {
        BaseTransformViewPresetSheet(
            isPresented: $isPresetSelectorPresented,
            transformGroups: screenModel.transformGroups,
            isCustomDisabled: screenModel.isCustomDisabled,
            isGroupDisabled: { group in
                screenModel.isGroupDisabled(group)
            },
            customSelectionBinding: customSelectionBinding(),
            groupSelectionBinding: groupSelectionBinding(for:),
            maskingToggleBinding: maskingToggleBinding(_:)
        )
    }

    var inputSection: some View {
        BaseTransformInputSection(
            isQRCodeInput: screenModel.presetSelectionState.selectedPresets.contains(.qrDecode),
            sourceText: $screenModel.sourceText,
            selectedSourceText: $screenModel.selectedSourceText,
            importedImageName: screenModel.importedImageName,
            isImporterPresented: $isImporterPresented,
            hasSelectedImage: screenModel.selectedImageData != nil,
            canCreateMappingFromSelection: screenModel.selectedSourceTextValue != nil,
            createMappingFromSelection: presentMappingFromSelection(text:),
            createMappingFromCurrentSelection: presentMappingFromSelection,
            pasteSourceText: screenModel.pasteSourceText,
            clearSourceText: screenModel.clearSourceText,
            clearSelectedImage: screenModel.clearSelectedImage,
            handleDrop: handleDrop(providers:)
        )
    }

    var resultSection: some View {
        BaseTransformResultSection(
            isQREncode: screenModel.presetSelectionState.selectedPresets.contains(.qrEncode),
            resultText: screenModel.resultText,
            qrImage: screenModel.qrImage,
            sourceText: screenModel.sourceText
        )
    }

    var actionSection: some View {
        BaseTransformActionSection(
            isDisabled: screenModel.isRunDisabled,
            runTransform: runTransform
        )
    }

    var mappingCreationSheet: some View {
        NavigationStack {
            MappingEditView(
                rule: nil,
                isPresented: $isPresentingMappingCreation,
                prefilledSource: screenModel.pendingSourceForMapping
            )
        }
    }
}

private extension BaseTransformView {
    func customSelectionBinding() -> Binding<Bool> {
        Binding(
            get: {
                screenModel.presetSelectionState.selectedPresets.contains(.customMapping)
            },
            set: { isSelected in
                screenModel.updateCustomSelection(
                    isSelected: isSelected,
                    preferencesStore: preferencesStore
                )
            }
        )
    }

    func groupSelectionBinding(for group: TransformGroup) -> Binding<TransformPreset?> {
        Binding(
            get: {
                screenModel.presetSelectionState.selectedPreset(in: group)
            },
            set: { selectedPreset in
                screenModel.updateGroupSelection(
                    group: group,
                    selectedPreset: selectedPreset,
                    preferencesStore: preferencesStore
                )
            }
        )
    }

    func openPresetSelector() {
        screenModel.openPresetSelector()
        isPresetSelectorPresented = true
    }

    func presentMappingFromSelection() {
        if screenModel.prepareMappingCreationFromCurrentSelection() {
            isPresentingMappingCreation = true
        }
    }

    func presentMappingFromSelection(text: String) {
        if screenModel.prepareMappingCreation(from: text) {
            isPresentingMappingCreation = true
        }
    }

    func maskingToggleBinding(
        _ keyPath: WritableKeyPath<MaskingPreferences, Bool>
    ) -> Binding<Bool> {
        Binding(
            get: {
                preferencesStore.preferences.maskingPreferences[keyPath: keyPath]
            },
            set: { newValue in
                preferencesStore.update { preferences in
                    preferences.maskingPreferences[keyPath: keyPath] = newValue
                }
            }
        )
    }

    func runTransform() {
        Task {
            await screenModel.executeTransform(
                context: context,
                mappingRules: mappingRules,
                preferencesStore: preferencesStore
            )
        }
    }

    func handleDrop(providers: [NSItemProvider]) {
        guard let provider = providers.first(where: { provider in
            provider.hasItemConformingToTypeIdentifier(UTType.image.identifier)
        }) else {
            return
        }
        let suggestedName = provider.suggestedName
        provider.loadDataRepresentation(forTypeIdentifier: UTType.image.identifier) { data, _ in
            guard let data else {
                return
            }

            Task { @MainActor in
                screenModel.applyImportedImageData(
                    data,
                    suggestedName: suggestedName
                )
            }
        }
    }
}
