@testable import NormleLibrary
import SwiftData
import Testing

struct NormleModelContainerFactoryTests {
    @MainActor
    @Test func makeInMemoryContainerSupportsPersistence() throws {
        let container = try NormleModelContainerFactory.makeInMemory()
        let context = container.mainContext
        let descriptor = FetchDescriptor<TransformRecord>()
        let baselineCount = try context.fetch(descriptor).count

        _ = TransformRecord.create(
            context: context,
            sourceText: "source",
            targetText: "target"
        )
        try context.save()

        let updatedCount = try context.fetch(descriptor).count
        #expect(updatedCount == baselineCount + 1)
    }

    @MainActor
    @Test func makeContainerWithoutCloudSyncSupportsPersistence() throws {
        let container = try NormleModelContainerFactory.make(
            cloudSyncEnabled: false
        )
        let context = container.mainContext
        let descriptor = FetchDescriptor<TransformRecord>()
        let baselineCount = try context.fetch(descriptor).count

        _ = TransformRecord.create(
            context: context,
            sourceText: "source",
            targetText: "target"
        )
        try context.save()

        let updatedCount = try context.fetch(descriptor).count
        #expect(updatedCount == baselineCount + 1)
    }
}
