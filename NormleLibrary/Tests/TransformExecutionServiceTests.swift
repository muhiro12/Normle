@testable import NormleLibrary
import SwiftData
import Testing

struct TransformExecutionServiceTests {
    @Test func runAndSavePersistsRecordWithMappings() throws {
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

        let result = TransformExecutionService.runAndSave(
            context: context,
            sourceText: "Secret",
            presets: presets,
            maskRules: maskRules,
            options: options,
            imageData: nil
        )

        switch result {
        case .success(let output):
            #expect(output.outputText == "ALIAS")

            let records = try context.fetch(FetchDescriptor<TransformRecord>())
            #expect(records.count == 1)
            #expect(records.first?.targetText == "ALIAS")
            #expect(records.first?.mappings.first?.masked == "ALIAS")
        case .failure:
            #expect(false)
        }
    }

    @Test func runAndSaveReturnsPipelineError() {
        let context = testContext
        let result = TransformExecutionService.runAndSave(
            context: context,
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

        switch result {
        case .success:
            #expect(false)
        case .failure(let error):
            switch error {
            case .pipeline(let pipelineError):
                #expect(pipelineError == .missingImageData)
            case .persistence:
                #expect(false)
            }
        }
    }
}
