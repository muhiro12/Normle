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
        let configuration: ModelConfiguration = .init(isStoredInMemoryOnly: true)
        do {
            return try .init(
                for: TransformRecord.self,
                MappingRule.self,
                Tag.self,
                configurations: configuration
            )
        } catch {
            fatalError(error.localizedDescription)
        }
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
}
