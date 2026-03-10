//
//  MappingRuleTransferService.swift
//  Normle
//
//  Created by Hiromu Nakano on 2025/11/23.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import Foundation
import SwiftData

/// Imports and exports collections of mapping rules.
public enum MappingRuleTransferService {
    private enum TransferFormat {
        static let currentVersion = 2
        static let minimumSupportedVersion = 1
    }

    private enum PayloadCodingKeys: String, CodingKey {
        case date
        case source
        case target
        case isEnabled
        case original
        case masked
    }

    /// Describes how imported rules should be merged with existing rules.
    public enum ImportPolicy {
        /// Replaces all existing rules with the imported rules.
        case replaceAll
        /// Updates matching rules and inserts non-matching rules.
        case mergeExisting
        /// Inserts imported rules without attempting to match existing rules.
        case appendNew
    }

    /// Summarizes the result of an import operation.
    public struct ImportResult {
        /// The number of newly inserted rules.
        public let insertedCount: Int
        /// The number of existing rules updated during import.
        public let updatedCount: Int
        /// The total number of rules after import completes.
        public let totalCount: Int

        /// Returns summary lines built from the import counters.
        public func summaryLines(
            insertedText: (Int) -> String,
            updatedText: (Int) -> String,
            totalText: (Int) -> String
        ) -> [String] {
            [
                insertedText(insertedCount),
                updatedText(updatedCount),
                totalText(totalCount)
            ]
        }
    }

    private struct Payload: Codable {
        let date: Date
        let source: String
        let target: String
        let isEnabled: Bool

        init(
            date: Date,
            source: String,
            target: String,
            isEnabled: Bool
        ) {
            self.date = date
            self.source = source
            self.target = target
            self.isEnabled = isEnabled
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(
                keyedBy: PayloadCodingKeys.self
            )
            date = try container.decode(
                Date.self,
                forKey: .date
            )
            if let decodedSource = try container.decodeIfPresent(
                String.self,
                forKey: .source
            ) {
                source = decodedSource
            } else {
                source = try container.decode(
                    String.self,
                    forKey: .original
                )
            }
            if let decodedTarget = try container.decodeIfPresent(
                String.self,
                forKey: .target
            ) {
                target = decodedTarget
            } else {
                target = try container.decode(
                    String.self,
                    forKey: .masked
                )
            }
            isEnabled = try container.decode(
                Bool.self,
                forKey: .isEnabled
            )
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(
                keyedBy: PayloadCodingKeys.self
            )
            try container.encode(date, forKey: .date)
            try container.encode(source, forKey: .source)
            try container.encode(target, forKey: .target)
            try container.encode(isEnabled, forKey: .isEnabled)
        }
    }

    private struct Transfer: Codable {
        let version: Int
        let exportedAt: Date
        let rules: [Payload]
    }

    /// Errors that can occur while importing transfer data.
    public enum TransferError: Error {
        /// The imported data uses an unsupported transfer version.
        case unsupportedVersion
        /// The imported data is empty.
        case missingData
    }
}

public extension MappingRuleTransferService {
    /// Exports all mapping rules from the provided model context.
    static func exportData(
        context: ModelContext
    ) throws -> Data {
        let descriptor = FetchDescriptor<MappingRule>(
            sortBy: [
                .init(\MappingRule.date, order: .forward)
            ]
        )
        let rules = try context.fetch(descriptor)
        return try exportData(rules: rules)
    }

    /// Exports the provided mapping rules to transfer data.
    static func exportData(
        rules: [MappingRule]
    ) throws -> Data {
        let payloads = rules.map { rule in
            Payload(
                date: rule.date,
                source: rule.source,
                target: rule.target,
                isEnabled: rule.isEnabled
            )
        }

        let transfer = Transfer(
            version: TransferFormat.currentVersion,
            exportedAt: Date(),
            rules: payloads
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try encoder.encode(transfer)
    }

    /// Imports mapping rules from transfer data using the selected policy.
    @discardableResult
    static func importData(
        _ data: Data,
        context: ModelContext,
        policy: ImportPolicy
    ) throws -> ImportResult {
        let transfer = try decodeTransfer(from: data)
        let existing = try fetchRules(context: context)
        let counts = try importRules(
            transfer.rules,
            existing: existing,
            policy: policy,
            context: context
        )
        try context.save()
        return .init(
            insertedCount: counts.insertedCount,
            updatedCount: counts.updatedCount,
            totalCount: try fetchRules(context: context).count
        )
    }
}

private extension MappingRuleTransferService {
    private struct ImportCounts {
        var insertedCount = 0
        var updatedCount = 0
    }

    private static func decodeTransfer(from data: Data) throws -> Transfer {
        guard data.isEmpty == false else {
            throw TransferError.missingData
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let transfer = try decoder.decode(
            Transfer.self,
            from: data
        )

        let supportedVersions = [
            TransferFormat.minimumSupportedVersion,
            TransferFormat.currentVersion
        ]
        guard supportedVersions.contains(transfer.version) else {
            throw TransferError.unsupportedVersion
        }

        return transfer
    }

    private static func fetchRules(context: ModelContext) throws -> [MappingRule] {
        try context.fetch(FetchDescriptor<MappingRule>())
    }

    private static func importRules(
        _ payloads: [Payload],
        existing: [MappingRule],
        policy: ImportPolicy,
        context: ModelContext
    ) throws -> ImportCounts {
        switch policy {
        case .replaceAll:
            return try replaceAll(
                payloads,
                existing: existing,
                context: context
            )
        case .mergeExisting:
            return try mergeExisting(
                payloads,
                existing: existing,
                context: context
            )
        case .appendNew:
            return try appendNew(
                payloads,
                context: context
            )
        }
    }

    private static func replaceAll(
        _ payloads: [Payload],
        existing: [MappingRule],
        context: ModelContext
    ) throws -> ImportCounts {
        existing.forEach(context.delete)

        var counts = ImportCounts()
        for payload in payloads {
            try insert(
                payload: payload,
                context: context
            )
            counts.insertedCount += 1
        }
        return counts
    }

    private static func mergeExisting(
        _ payloads: [Payload],
        existing: [MappingRule],
        context: ModelContext
    ) throws -> ImportCounts {
        var counts = ImportCounts()

        for payload in payloads {
            if let match = existing.first(where: { rule in
                rule.source == payload.source ||
                    rule.target == payload.target
            }) {
                try apply(
                    payload: payload,
                    to: match,
                    context: context
                )
                counts.updatedCount += 1
                continue
            }

            try insert(
                payload: payload,
                context: context
            )
            counts.insertedCount += 1
        }

        return counts
    }

    private static func appendNew(
        _ payloads: [Payload],
        context: ModelContext
    ) throws -> ImportCounts {
        var counts = ImportCounts()
        for payload in payloads {
            try insert(
                payload: payload,
                context: context
            )
            counts.insertedCount += 1
        }
        return counts
    }

    private static func insert(
        payload: Payload,
        context: ModelContext
    ) throws {
        try MappingRule.create(
            context: context,
            source: payload.source,
            target: payload.target,
            isEnabled: payload.isEnabled,
            date: payload.date
        )
    }

    private static func apply(
        payload: Payload,
        to rule: MappingRule,
        context: ModelContext
    ) throws {
        try rule.update(
            context: context,
            source: payload.source,
            target: payload.target,
            isEnabled: payload.isEnabled,
            date: payload.date
        )
    }
}
