//
//  PreviewData.swift
//  Normle
//
//  Created by Hiromu Nakano on 2026/02/04.
//

import NormleLibrary
import SwiftData
import SwiftUI

@MainActor
enum PreviewData {
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
                date: Date().addingTimeInterval(-3_600),
                source: "alice@example.com",
                target: "[Email 1]",
                isEnabled: true
            )
            try MappingRule.create(
                context: context,
                date: Date().addingTimeInterval(-7_200),
                source: "Tokyo",
                target: "[City]",
                isEnabled: false
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
}
