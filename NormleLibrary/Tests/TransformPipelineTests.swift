@testable import NormleLibrary
import Testing

struct TransformPipelineTests {
    @Test func customMappingRunsBeforeBuiltinTransforms() {
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

        switch result {
        case .success(let output):
            #expect(output.outputText == "ALIAS")
            #expect(output.recordSourceText == "Secret")
            #expect(output.recordTargetText == "ALIAS")
            #expect(output.qrImage == nil)
        case .failure:
            #expect(false)
        }
    }

    @Test func returnsBaseTransformErrorWhenTransformFails() {
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

        switch result {
        case .success:
            #expect(false)
        case .failure(let error):
            #expect(error == .baseTransform(.invalidBase64))
        }
    }

    @Test func returnsMissingImageDataWhenQRCodeImageIsAbsent() {
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

        switch result {
        case .success:
            #expect(false)
        case .failure(let error):
            #expect(error == .missingImageData)
        }
    }

    @Test func returnsQRCodeImageForEncodePreset() {
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

        switch result {
        case .success(let output):
            #expect(output.outputText.isEmpty)
            #expect(output.qrImage != nil)
            #expect(output.recordSourceText == "hello")
            #expect(output.recordTargetText.isEmpty)
        case .failure:
            #expect(false)
        }
    }
}
