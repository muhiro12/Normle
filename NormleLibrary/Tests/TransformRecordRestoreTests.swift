@testable import NormleLibrary
import Testing

struct TransformRecordRestoreTests {
    @Test func restoreMappingsUsesSavedMappingsWhenAvailable() throws {
        let context = testContext
        let mapping = Mapping(
            original: "alice@example.com",
            masked: "EMAIL(1)",
            kind: .email,
            occurrenceCount: 1
        )

        let record = try TransformRecordService.saveRecord(
            context: context,
            sourceText: "alice@example.com",
            targetText: "MASKED TEXT",
            mappings: [mapping]
        )

        let mappings = record.restoreMappings

        #expect(mappings.count == 1)
        #expect(mappings.first?.original == "alice@example.com")
        #expect(mappings.first?.masked == "EMAIL(1)")
    }

    @Test func restoreMappingsFallsBackToSourceAndTargetTexts() throws {
        let context = testContext

        let record = try TransformRecordService.saveRecord(
            context: context,
            sourceText: "alice@example.com",
            targetText: "Email(1)",
            mappings: []
        )

        let mappings = record.restoreMappings

        #expect(mappings.count == 1)
        #expect(mappings.first?.original == "alice@example.com")
        #expect(mappings.first?.masked == "Email(1)")
    }

    @Test func restoreMappingsIsEmptyWithoutRetainedSourceText() throws {
        let context = testContext

        let record = try TransformRecordService.saveRecord(
            context: context,
            sourceText: nil,
            targetText: "Email(1)",
            mappings: []
        )

        #expect(record.restoreMappings.isEmpty)
    }
}
