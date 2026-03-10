//
//  TransformPipelineTests.swift
//  Normle
//
//  Created by Hiromu Nakano on 2026/01/12.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

@testable import NormleLibrary
import Testing

struct TransformPipelineTests {
    @Test
    func customMappingRunsBeforeBuiltinTransforms() {
        let pipeline = TransformPipeline()
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

        let result = pipeline.run(
            sourceText: "Secret",
            presets: presets,
            maskRules: maskRules,
            options: options,
            imageData: nil
        )

        guard case let .success(output) = result else {
            Issue.record("Expected transform pipeline to succeed.")
            return
        }

        #expect(output.outputText == "ALIAS")
        #expect(output.recordSourceText == "Secret")
        #expect(output.recordTargetText == "ALIAS")
        #expect(output.qrImage == nil)
        #expect(output.mappings.count == 1)
        #expect(output.mappings.first?.original == "Secret")
        #expect(output.mappings.first?.masked == "ALIAS")
    }

    @Test
    func returnsBaseTransformErrorWhenTransformFails() {
        let pipeline = TransformPipeline()
        let presets: [TransformPreset] = [
            .builtIn(.base64Decode)
        ]
        let options = MaskingOptions(
            isURLMaskingEnabled: false,
            isEmailMaskingEnabled: false,
            isPhoneMaskingEnabled: false
        )

        let result = pipeline.run(
            sourceText: "not-base64",
            presets: presets,
            maskRules: [],
            options: options,
            imageData: nil
        )

        guard case let .failure(error) = result else {
            Issue.record("Expected base64 decode to fail.")
            return
        }

        #expect(error == .baseTransform(.invalidBase64))
    }

    @Test
    func returnsMissingImageDataWhenQRCodeImageIsAbsent() {
        let pipeline = TransformPipeline()
        let presets: [TransformPreset] = [
            .builtIn(.qrDecode)
        ]
        let options = MaskingOptions(
            isURLMaskingEnabled: false,
            isEmailMaskingEnabled: false,
            isPhoneMaskingEnabled: false
        )

        let result = pipeline.run(
            sourceText: String(),
            presets: presets,
            maskRules: [],
            options: options,
            imageData: nil
        )

        guard case let .failure(error) = result else {
            Issue.record("Expected QR decode without image data to fail.")
            return
        }

        #expect(error == .missingImageData)
    }

    @Test
    func returnsQRCodeImageForEncodePreset() {
        let pipeline = TransformPipeline()
        let presets: [TransformPreset] = [
            .builtIn(.qrEncode)
        ]
        let options = MaskingOptions(
            isURLMaskingEnabled: false,
            isEmailMaskingEnabled: false,
            isPhoneMaskingEnabled: false
        )

        let result = pipeline.run(
            sourceText: "hello",
            presets: presets,
            maskRules: [],
            options: options,
            imageData: nil
        )

        guard case let .success(output) = result else {
            Issue.record("Expected QR encode preset to succeed.")
            return
        }

        #expect(output.outputText.isEmpty)
        #expect(output.qrImage != nil)
        #expect(output.recordSourceText == "hello")
        #expect(output.recordTargetText.isEmpty)
        #expect(output.mappings.isEmpty)
    }
}
