@testable import NormleLibrary
import SwiftData
import Testing

struct TransformRecordServiceTests {
    @Test func savingRecordsPersistsSourceAndTargetText() throws {
        let context = testContext
        let mapping = Mapping(
            original: "secret",
            masked: "Alias(1)",
            kind: .other,
            occurrenceCount: 2
        )

        let first = try TransformRecordService.saveRecord(
            context: context,
            sourceText: "",
            targetText: "masked-1",
            mappings: [mapping]
        )

        let descriptor = FetchDescriptor<TransformRecord>(
            sortBy: [
                .init(\.date, order: .reverse)
            ]
        )
        let records = try context.fetch(descriptor)

        #expect(records.count == 1)
        #expect(records.first == first)
        #expect(records.first?.sourceText == "")
        #expect(records.first?.targetText == "masked-1")
    }
}
