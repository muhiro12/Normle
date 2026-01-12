//
//  MappingRuleTransferService.swift
//
//
//  Created by Hiromu Nakano on 2025/11/23.
//

import Foundation
import SwiftData

public enum MappingRuleTransferService {
    public enum ImportPolicy {
        case replaceAll
        case mergeExisting
        case appendNew
    }

    public struct ImportResult {
        public let insertedCount: Int
        public let updatedCount: Int
        public let totalCount: Int

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

        enum CodingKeys: String, CodingKey {
            case date
            case source
            case target
            case isEnabled
            case original
            case masked
        }

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
            let container = try decoder.container(keyedBy: CodingKeys.self)
            date = try container.decode(Date.self, forKey: .date)
            if let decodedSource = try container.decodeIfPresent(String.self, forKey: .source) {
                source = decodedSource
            } else {
                source = try container.decode(String.self, forKey: .original)
            }
            if let decodedTarget = try container.decodeIfPresent(String.self, forKey: .target) {
                target = decodedTarget
            } else {
                target = try container.decode(String.self, forKey: .masked)
            }
            isEnabled = try container.decode(Bool.self, forKey: .isEnabled)
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
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

    public enum TransferError: Error {
        case unsupportedVersion
        case missingData
    }
}

public extension MappingRuleTransferService {
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
            version: 2,
            exportedAt: Date(),
            rules: payloads
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try encoder.encode(transfer)
    }

    @discardableResult
    static func importData(
        _ data: Data,
        context: ModelContext,
        policy: ImportPolicy
    ) throws -> ImportResult {
        guard data.isEmpty == false else {
            throw TransferError.missingData
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let transfer = try decoder.decode(Transfer.self, from: data)

        guard [1, 2].contains(transfer.version) else {
            throw TransferError.unsupportedVersion
        }

        let existing = try context.fetch(
            FetchDescriptor<MappingRule>()
        )

        var insertedCount = 0
        var updatedCount = 0

        switch policy {
        case .replaceAll:
            existing.forEach(context.delete)
            for payload in transfer.rules {
                try insert(
                    payload: payload,
                    context: context
                )
                insertedCount += 1
            }
        case .mergeExisting:
            for payload in transfer.rules {
                if let match = existing.first(where: {
                    $0.source == payload.source ||
                        $0.target == payload.target
                }) {
                    try apply(
                        payload: payload,
                        to: match,
                        context: context
                    )
                    updatedCount += 1
                    continue
                }

                try insert(
                    payload: payload,
                    context: context
                )
                insertedCount += 1
            }
        case .appendNew:
            for payload in transfer.rules {
                try insert(
                    payload: payload,
                    context: context
                )
                insertedCount += 1
            }
        }

        try context.save()

        let totalCount = try context.fetch(
            FetchDescriptor<MappingRule>()
        ).count

        return .init(
            insertedCount: insertedCount,
            updatedCount: updatedCount,
            totalCount: totalCount
        )
    }
}

private extension MappingRuleTransferService {
    private static func insert(
        payload: Payload,
        context: ModelContext
    ) throws {
        try MappingRule.create(
            context: context,
            date: payload.date,
            source: payload.source,
            target: payload.target,
            isEnabled: payload.isEnabled
        )
    }

    private static func apply(
        payload: Payload,
        to rule: MappingRule,
        context: ModelContext
    ) throws {
        try rule.update(
            context: context,
            date: payload.date,
            source: payload.source,
            target: payload.target,
            isEnabled: payload.isEnabled
        )
    }
}
