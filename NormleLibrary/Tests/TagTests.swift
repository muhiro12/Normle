@testable import NormleLibrary
import SwiftData
import Testing

struct TagTests {
    @Test func createReturnsExistingTagForSameNameAndType() throws {
        let context = testContext

        let firstTag = try Tag.create(
            context: context,
            name: "Important",
            type: .maskRule
        )
        let secondTag = try Tag.create(
            context: context,
            name: "Important",
            type: .maskRule
        )

        let tags = try context.fetch(FetchDescriptor<NormleLibrary.Tag>())

        #expect(tags.count == 1)
        #expect(firstTag == secondTag)
    }

    @Test func createSeparatesTagsByType() throws {
        let context = testContext

        let ruleTag = try Tag.create(
            context: context,
            name: "Important",
            type: .maskRule
        )
        let recordTag = try Tag.create(
            context: context,
            name: "Important",
            type: .maskRecord
        )

        let tags = try context.fetch(FetchDescriptor<NormleLibrary.Tag>())

        #expect(tags.count == 2)
        #expect(ruleTag.type == .maskRule)
        #expect(recordTag.type == .maskRecord)
        #expect(ruleTag != recordTag)
    }

    @Test func createIgnoringDuplicatesAlwaysInserts() throws {
        let context = testContext

        _ = try Tag.createIgnoringDuplicates(
            context: context,
            name: "Transient",
            type: .maskRule
        )
        _ = try Tag.createIgnoringDuplicates(
            context: context,
            name: "Transient",
            type: .maskRule
        )

        let tags = try context.fetch(FetchDescriptor<NormleLibrary.Tag>())

        #expect(tags.count == 2)
    }
}
