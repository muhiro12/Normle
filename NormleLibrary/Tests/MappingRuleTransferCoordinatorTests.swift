import Foundation
@testable import NormleLibrary
import Testing

struct MappingRuleTransferCoordinatorTests {
    @Test func exportDataReturnsEncodedRules() throws {
        let context = testContext
        _ = try MappingRule.create(
            context: context,
            source: "source",
            target: "target",
            isEnabled: true
        )
        try context.save()

        let data = try MappingRuleTransferCoordinator.exportData(
            context: context
        )

        #expect(data.isEmpty == false)
    }

    @Test func loadImportDataReadsFileContents() throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("json")
        let expected = Data("{}".utf8)
        try expected.write(to: url)
        defer {
            try? FileManager.default.removeItem(at: url)
        }

        let loaded = try MappingRuleTransferCoordinator.loadImportData(
            from: url
        )

        #expect(loaded == expected)
    }
}
