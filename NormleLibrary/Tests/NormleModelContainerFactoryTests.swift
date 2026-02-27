@testable import NormleLibrary
import SwiftData
import Testing

struct NormleModelContainerFactoryTests {
    private enum ForcedError: Error, Equatable {
        case cloudContainerUnavailable
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

    @MainActor
    @Test func makeWithFallbackDisablesCloudSyncAfterCloudFailure() throws {
        let localContainer = try NormleModelContainerFactory.make(
            cloudSyncEnabled: false
        )
        var capturedCloudError: ForcedError?

        let result = NormleModelContainerFactory.makeWithFallback(
            cloudSyncEnabled: true,
            buildContainer: { isCloudSyncEnabled in
                if isCloudSyncEnabled {
                    throw ForcedError.cloudContainerUnavailable
                }
                return localContainer
            },
            onCloudContainerError: { error in
                capturedCloudError = error as? ForcedError
            },
            onLocalContainerError: { _ in
            }
        )

        #expect(result.isCloudSyncEnabled == false)
        #expect(capturedCloudError == .cloudContainerUnavailable)
    }

    @MainActor
    @Test func makeWithFallbackKeepsCloudSyncStateWhenLocalOnly() throws {
        let result = NormleModelContainerFactory.makeWithFallback(
            cloudSyncEnabled: false
        )

        #expect(result.isCloudSyncEnabled == false)

        let context = result.container.mainContext
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
