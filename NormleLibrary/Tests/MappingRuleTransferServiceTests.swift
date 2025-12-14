@testable import NormleLibrary
import SwiftData
import Testing

struct MappingRuleTransferServiceTests {
    @Test func exportAndReplaceImport() throws {
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

        #expect(result.insertedCount == 1)
        #expect(result.updatedCount == 0)

        let fetched = try importContext.fetch(FetchDescriptor<MappingRule>())
        #expect(fetched.count == 1)
        #expect(fetched.first?.target == "Alias")
    }

    @Test func mergeUpdatesExistingRule() throws {
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

        #expect(result.insertedCount == 0)
        #expect(result.updatedCount == 1)

        let fetched = try context.fetch(FetchDescriptor<MappingRule>())
        #expect(fetched.first?.target == "NewAlias")
    }

    @Test func appendCreatesNewIDsWhenDuplicated() throws {
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

        #expect(result.insertedCount == 1)
        #expect(result.updatedCount == 0)

        let fetched = try context.fetch(FetchDescriptor<MappingRule>())
        #expect(fetched.count == 2)
        #expect(fetched.contains { $0.source == "New" && $0.target == "NewAlias" })
    }

    @Test func importHandlesLegacyFieldNames() throws {
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
            Issue.record("Failed to build legacy payload")
            return
        }

        let result = try MappingRuleTransferService.importData(
            data,
            context: context,
            policy: .replaceAll
        )

        #expect(result.insertedCount == 1)
        #expect(result.updatedCount == 0)
        #expect(result.totalCount == 1)

        let fetched = try context.fetch(FetchDescriptor<MappingRule>())
        #expect(fetched.count == 1)
        #expect(fetched.first?.source == "Legacy")
        #expect(fetched.first?.target == "Alias")
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
