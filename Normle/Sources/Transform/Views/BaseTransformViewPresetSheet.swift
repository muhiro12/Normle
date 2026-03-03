//
//  BaseTransformViewPresetSheet.swift
//  Normle
//
//  Created by Hiromu Nakano on 2026/03/03.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import NormleLibrary
import SwiftUI

struct BaseTransformViewPresetSheet: View {
    @Binding var isPresented: Bool

    let transformGroups: [TransformGroup]
    let isCustomDisabled: Bool
    let isGroupDisabled: (TransformGroup) -> Bool
    let customSelectionBinding: Binding<Bool>
    let groupSelectionBinding: (TransformGroup) -> Binding<TransformPreset?>
    let maskingToggleBinding: (WritableKeyPath<MaskingPreferences, Bool>) -> Binding<Bool>

    var body: some View {
        NavigationStack {
            Form {
                maskingOptionsSection
                customPresetSection
                presetGroupSections
            }
            .navigationTitle("Presets")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        isPresented = false
                    }
                }
            }
        }
    }
}

private extension BaseTransformViewPresetSheet {
    var maskingOptionsSection: some View {
        Section("Masking Options") {
            Toggle(isOn: maskingToggleBinding(\.isURLMaskingEnabled)) {
                Text("Mask URLs")
            }
            Toggle(isOn: maskingToggleBinding(\.isEmailMaskingEnabled)) {
                Text("Mask emails")
            }
            Toggle(isOn: maskingToggleBinding(\.isPhoneMaskingEnabled)) {
                Text("Mask phone numbers")
            }
        }
    }

    var customPresetSection: some View {
        Section("Custom") {
            Picker("Custom", selection: customSelectionBinding) {
                Text("None")
                    .tag(false)
                Text(TransformPreset.customMapping.title)
                    .tag(true)
            }
            .pickerStyle(.segmented)
            .disabled(isCustomDisabled)

            Text("Applied first.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    var presetGroupSections: some View {
        ForEach(transformGroups) { group in
            Section(group.title) {
                Picker(group.title, selection: groupSelectionBinding(group)) {
                    Text("None")
                        .tag(Optional<TransformPreset>.none)
                    ForEach(group.options) { option in
                        Text(option.title)
                            .tag(TransformPreset?.some(option))
                    }
                }
                .pickerStyle(.segmented)
                .disabled(isGroupDisabled(group))
            }
        }
    }
}
