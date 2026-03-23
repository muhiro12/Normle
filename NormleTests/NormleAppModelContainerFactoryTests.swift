//
//  NormleAppModelContainerFactoryTests.swift
//  NormleTests
//
//  Created by Codex on 2026/03/23.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

@testable import Normle
import NormleLibrary
import SwiftData
import Testing

struct NormleAppModelContainerFactoryTests {
    private enum ForcedError: Error, Equatable {
        case cloudContainerUnavailable
    }

    @MainActor
    @Test
    func makeContainerWithoutCloudSyncSupportsPersistence() throws {
        let container = try NormleAppModelContainerFactory.makeAppModelContainer(
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
    @Test
    func makeInMemorySupportsPersistence() throws {
        let container = try NormleAppModelContainerFactory.makeInMemoryModelContainer()
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
    @Test
    func makeInMemorySupportsEntireSchema() throws {
        let container = try NormleAppModelContainerFactory.makeInMemoryModelContainer()
        let context = container.mainContext
        let mappingDescriptor = FetchDescriptor<MappingRule>()
        let tagDescriptor = FetchDescriptor<NormleLibrary.Tag>()

        #expect(try context.fetch(mappingDescriptor).isEmpty)
        #expect(try context.fetch(tagDescriptor).isEmpty)

        _ = try MappingRule.create(
            context: context,
            source: "email@example.com",
            target: "[Email]"
        )
        _ = NormleLibrary.Tag.createIgnoringDuplicates(
            context: context,
            name: "Sensitive",
            type: .maskRule
        )
        try context.save()

        #expect(try context.fetch(mappingDescriptor).count == 1)
        #expect(try context.fetch(tagDescriptor).count == 1)
    }

    @MainActor
    @Test
    func makeLiveContainerDisablesCloudSyncAfterCloudFailure() throws {
        let localContainer = try NormleAppModelContainerFactory.makeAppModelContainer(
            cloudSyncEnabled: false
        )
        var capturedCloudError: ForcedError?

        let result = NormleAppModelContainerFactory.makeLiveContainer(
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
                // Intentionally ignored in this scenario.
            }
        )

        #expect(result.isCloudSyncEnabled == false)
        #expect(capturedCloudError == .cloudContainerUnavailable)
    }

    @MainActor
    @Test
    func makeLiveContainerKeepsCloudSyncStateWhenLocalOnly() throws {
        let result = NormleAppModelContainerFactory.makeLiveContainer(
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
