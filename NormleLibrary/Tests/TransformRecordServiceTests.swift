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

    @Test func updateRecordUpdatesPersistedText() throws {
        let context = testContext

        let record = try TransformRecordService.saveRecord(
            context: context,
            sourceText: "source-1",
            targetText: "target-1",
            mappings: []
        )

        _ = try TransformRecordService.updateRecord(
            context: context,
            record: record,
            sourceText: "source-2",
            targetText: "target-2",
            mappings: []
        )

        let descriptor = FetchDescriptor<TransformRecord>()
        let records = try context.fetch(descriptor)

        #expect(records.count == 1)
        #expect(records.first?.sourceText == "source-2")
        #expect(records.first?.targetText == "target-2")
    }

    @Test func deleteRemovesRecord() throws {
        let context = testContext

        let record = try TransformRecordService.saveRecord(
            context: context,
            sourceText: "source",
            targetText: "target",
            mappings: []
        )

        try TransformRecordService.delete(
            context: context,
            record: record
        )

        let descriptor = FetchDescriptor<TransformRecord>()
        let records = try context.fetch(descriptor)

        #expect(records.isEmpty)
    }

    @Test func deleteAllRemovesAllRecords() throws {
        let context = testContext

        _ = try TransformRecordService.saveRecord(
            context: context,
            sourceText: "source-1",
            targetText: "target-1",
            mappings: []
        )
        _ = try TransformRecordService.saveRecord(
            context: context,
            sourceText: "source-2",
            targetText: "target-2",
            mappings: []
        )

        try TransformRecordService.deleteAll(context: context)

        let descriptor = FetchDescriptor<TransformRecord>()
        let records = try context.fetch(descriptor)

        #expect(records.isEmpty)
    }
}
