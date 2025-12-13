@testable import NormleLibrary
import SwiftData
import XCTest

final class MappingRuleTransferServiceTests: XCTestCase {
    func testExportAndReplaceImport() throws {
        let context = try makeContext()

        try MappingRule.create(
            context: context,
            source: "Secret",
            target: "Alias"
        )
        try context.save()

        let data = try MappingRuleTransferService.exportData(context: context)

        let importContext = try makeContext()
        let result = try MappingRuleTransferService.importData(
            data,
            context: importContext,
            policy: .replaceAll
        )

        XCTAssertEqual(result.insertedCount, 1)
        XCTAssertEqual(result.updatedCount, 0)

        let fetched = try importContext.fetch(FetchDescriptor<MappingRule>())
        XCTAssertEqual(fetched.count, 1)
        XCTAssertEqual(fetched.first?.target, "Alias")
    }

    func testMergeUpdatesExistingRule() throws {
        let context = try makeContext()

        try MappingRule.create(
            context: context,
            source: "Old",
            target: "OldAlias"
        )
        try context.save()

        let payloadContext = try makeContext()
        try MappingRule.create(
            context: payloadContext,
            source: "Old",
            target: "NewAlias"
        )

        let data = try MappingRuleTransferService.exportData(context: payloadContext)

        let result = try MappingRuleTransferService.importData(
            data,
            context: context,
            policy: .mergeExisting
        )

        XCTAssertEqual(result.insertedCount, 0)
        XCTAssertEqual(result.updatedCount, 1)

        let fetched = try context.fetch(FetchDescriptor<MappingRule>())
        XCTAssertEqual(fetched.first?.target, "NewAlias")
    }

    func testAppendCreatesNewIDsWhenDuplicated() throws {
        let context = try makeContext()

        try MappingRule.create(
            context: context,
            source: "Keep",
            target: "KeepAlias"
        )
        try context.save()

        let payloadContext = try makeContext()
        try MappingRule.create(
            context: payloadContext,
            source: "New",
            target: "NewAlias"
        )

        let data = try MappingRuleTransferService.exportData(context: payloadContext)

        let result = try MappingRuleTransferService.importData(
            data,
            context: context,
            policy: .appendNew
        )

        XCTAssertEqual(result.insertedCount, 1)
        XCTAssertEqual(result.updatedCount, 0)

        let fetched = try context.fetch(FetchDescriptor<MappingRule>())
        XCTAssertEqual(fetched.count, 2)
        XCTAssertTrue(fetched.contains { $0.source == "New" && $0.target == "NewAlias" })
    }

    func testImportHandlesLegacyFieldNames() throws {
        let context = try makeContext()
        let payload = """
        {
          "version": 1,
          "exportedAt": "2024-01-01T00:00:00Z",
          "rules": [
            {
              "date": "2024-01-01T00:00:00Z",
              "original": "Legacy",
              "masked": "Alias",
              "isEnabled": true
            }
          ]
        }
        """
        guard let data = payload.data(using: .utf8) else {
            XCTFail("Failed to build legacy payload")
            return
        }

        let result = try MappingRuleTransferService.importData(
            data,
            context: context,
            policy: .replaceAll
        )

        XCTAssertEqual(result.insertedCount, 1)
        XCTAssertEqual(result.updatedCount, 0)
        XCTAssertEqual(result.totalCount, 1)

        let fetched = try context.fetch(FetchDescriptor<MappingRule>())
        XCTAssertEqual(fetched.count, 1)
        XCTAssertEqual(fetched.first?.source, "Legacy")
        XCTAssertEqual(fetched.first?.target, "Alias")
    }
}

private extension MappingRuleTransferServiceTests {
    func makeContext() throws -> ModelContext {
        let container = try ModelContainer(
            for: MappingRule.self,
            Tag.self,
            configurations: .init(isStoredInMemoryOnly: true)
        )
        return ModelContext(container)
    }
}
