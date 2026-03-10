//
//  TransformExecutionServiceTests.swift
//  Normle
//
//  Created by Hiromu Nakano on 2026/02/27.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

@testable import NormleLibrary
import SwiftData
import Testing

struct TransformExecutionServiceTests {
    @Test
    func runAndSavePersistsRecordWithMappings() throws {
        let context = testContext
        let presets: [TransformPreset] = [
            .customMapping,
            .builtIn(.uppercase)
        ]
        let maskRules: [MaskingRule] = [
            .init(
                original: "Secret",
                masked: "Alias",
                kind: .custom
            )
        ]
        let options = MaskingOptions(
            isURLMaskingEnabled: false,
            isEmailMaskingEnabled: false,
            isPhoneMaskingEnabled: false
        )

        let result = TransformExecutionService(context: context).runAndSave(
            sourceText: "Secret",
            presets: presets,
            maskRules: maskRules,
            options: options,
            imageData: nil
        )

        guard case let .success(output) = result else {
            Issue.record("Expected transform execution to succeed.")
            return
        }

        #expect(output.outputText == "ALIAS")

        let records = try context.fetch(FetchDescriptor<TransformRecord>())
        #expect(records.count == 1)
        #expect(records.first?.targetText == "ALIAS")
        #expect(records.first?.mappings.first?.masked == "ALIAS")
    }

    @Test
    func runAndSaveReturnsPipelineError() {
        let context = testContext
        let result = TransformExecutionService(context: context).runAndSave(
            sourceText: String(),
            presets: [.builtIn(.qrDecode)],
            maskRules: [],
            options: .init(
                isURLMaskingEnabled: false,
                isEmailMaskingEnabled: false,
                isPhoneMaskingEnabled: false
            ),
            imageData: nil
        )

        guard case let .failure(error) = result else {
            Issue.record("Expected transform execution to fail.")
            return
        }

        guard case let .pipeline(pipelineError) = error else {
            Issue.record("Expected a pipeline error.")
            return
        }

        #expect(pipelineError == .missingImageData)
    }
}
