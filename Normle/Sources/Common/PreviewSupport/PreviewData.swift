//
//  PreviewData.swift
//  Normle
//
//  Created by Hiromu Nakano on 2026/02/04.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import NormleLibrary
import SwiftData
import SwiftUI

@MainActor
enum PreviewData {
    private enum TimeIntervalOffset {
        static let recentMapping = -3_600.0
        static let olderMapping = -7_200.0
        static let sampleMapping = -1_800.0
    }

    static func makeContainer() -> ModelContainer {
        // Xcode previews have been unreliable with the in-memory container in the app target.
        // Use a local-only store for previews, then wipe it so every render starts clean.
        let container = NormleModelContainerFactory.makeWithFallback(
            cloudSyncEnabled: false
        ).container
        clearAllPreviewData(
            in: container
        )
        return container
    }

    static func seed(container: ModelContainer) {
        let context = container.mainContext
        do {
            try MappingRule.create(
                context: context,
                source: "alice@example.com",
                target: "[Email 1]",
                isEnabled: true,
                date: Date().addingTimeInterval(TimeIntervalOffset.recentMapping)
            )
            try MappingRule.create(
                context: context,
                source: "Tokyo",
                target: "[City]",
                isEnabled: false,
                date: Date().addingTimeInterval(TimeIntervalOffset.olderMapping)
            )
            _ = TransformRecord.create(
                context: context,
                sourceText: "alice@example.com",
                targetText: "[Email 1]"
            )
            _ = TransformRecord.create(
                context: context,
                sourceText: nil,
                targetText: "[Redacted]"
            )
            try context.save()
        } catch {
            assertionFailure(error.localizedDescription)
        }
    }

    static func makeSampleMappingRule(
        container: ModelContainer
    ) -> MappingRule {
        let context = container.mainContext
        do {
            let rule = try MappingRule.create(
                context: context,
                source: "Example",
                target: "[Masked]",
                isEnabled: true,
                date: Date().addingTimeInterval(TimeIntervalOffset.sampleMapping)
            )
            try context.save()
            return rule
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    static func makeSampleTransformRecord(
        container: ModelContainer
    ) -> TransformRecord {
        let context = container.mainContext
        let record = TransformRecord.create(
            context: context,
            sourceText: "alice@example.com",
            targetText: "[Email 1]"
        )
        do {
            try context.save()
        } catch {
            assertionFailure(error.localizedDescription)
        }
        return record
    }

    private static func clearAllPreviewData(
        in container: ModelContainer
    ) {
        let context = container.mainContext

        do {
            try deleteAll(
                of: TransformRecord.self,
                context: context
            )
            try deleteAll(
                of: MappingRule.self,
                context: context
            )
            try deleteAll(
                of: Tag.self,
                context: context
            )
            try context.save()
        } catch {
            assertionFailure(error.localizedDescription)
        }
    }

    private static func deleteAll<Model: PersistentModel>(
        of _: Model.Type,
        context: ModelContext
    ) throws {
        let descriptor = FetchDescriptor<Model>()
        try context.fetch(descriptor).forEach { model in
            context.delete(model)
        }
    }
}
