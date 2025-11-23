@testable import MaskleLibrary
import SwiftData
import XCTest

final class ManualRuleTransferServiceTests: XCTestCase {
    func testExportAndReplaceImport() throws {
        let context = try makeContext()

        ManualRule.create(
            context: context,
            uuid: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!,
            original: "Secret",
            alias: "Alias",
            kind: .person
        )
        try context.save()

        let data = try ManualRuleTransferService.exportData(context: context)

        let importContext = try makeContext()
        let result = try ManualRuleTransferService.importData(
            data,
            context: importContext,
            policy: .replaceAll
        )

        XCTAssertEqual(result.insertedCount, 1)
        XCTAssertEqual(result.updatedCount, 0)

        let fetched = try importContext.fetch(FetchDescriptor<ManualRule>())
        XCTAssertEqual(fetched.count, 1)
        XCTAssertEqual(fetched.first?.alias, "Alias")
        XCTAssertEqual(fetched.first?.kindID, MappingKind.person.rawValue)
    }

    func testMergeUpdatesExistingRule() throws {
        let context = try makeContext()
        let existingID = UUID(uuidString: "22222222-2222-2222-2222-222222222222")!

        ManualRule.create(
            context: context,
            uuid: existingID,
            original: "Old",
            alias: "OldAlias",
            kind: .project
        )
        try context.save()

        let payloadContext = try makeContext()
        ManualRule.create(
            context: payloadContext,
            uuid: existingID,
            original: "Old",
            alias: "NewAlias",
            kind: .project
        )

        let data = try ManualRuleTransferService.exportData(context: payloadContext)

        let result = try ManualRuleTransferService.importData(
            data,
            context: context,
            policy: .mergeExisting
        )

        XCTAssertEqual(result.insertedCount, 0)
        XCTAssertEqual(result.updatedCount, 1)

        let fetched = try context.fetch(FetchDescriptor<ManualRule>())
        XCTAssertEqual(fetched.first?.alias, "NewAlias")
    }

    func testAppendCreatesNewIDsWhenDuplicated() throws {
        let context = try makeContext()
        let duplicateID = UUID(uuidString: "33333333-3333-3333-3333-333333333333")!

        ManualRule.create(
            context: context,
            uuid: duplicateID,
            original: "Keep",
            alias: "KeepAlias",
            kind: .other
        )
        try context.save()

        let payloadContext = try makeContext()
        ManualRule.create(
            context: payloadContext,
            uuid: duplicateID,
            original: "New",
            alias: "NewAlias",
            kind: .other
        )

        let data = try ManualRuleTransferService.exportData(context: payloadContext)

        let result = try ManualRuleTransferService.importData(
            data,
            context: context,
            policy: .appendNew
        )

        XCTAssertEqual(result.insertedCount, 1)
        XCTAssertEqual(result.updatedCount, 0)

        let fetched = try context.fetch(FetchDescriptor<ManualRule>())
        XCTAssertEqual(fetched.count, 2)
        XCTAssertTrue(fetched.contains { $0.original == "New" && $0.alias == "NewAlias" })
    }
}

private extension ManualRuleTransferServiceTests {
    func makeContext() throws -> ModelContext {
        let container = try ModelContainer(
            for: ManualRule.self,
            configurations: .init(isStoredInMemoryOnly: true)
        )
        return ModelContext(container)
    }
}
