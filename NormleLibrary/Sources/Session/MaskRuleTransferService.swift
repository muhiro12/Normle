//
//  MaskRuleTransferService.swift
//
//
//  Created by Hiromu Nakano on 2025/11/23.
//

import Foundation
import SwiftData

public enum MaskRuleTransferService {
    public enum ImportPolicy {
        case replaceAll
        case mergeExisting
        case appendNew
    }

    public struct ImportResult {
        public let insertedCount: Int
        public let updatedCount: Int
        public let totalCount: Int
    }

    private struct Payload: Codable {
        let date: Date
        let original: String
        let masked: String
        let isEnabled: Bool
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

public extension MaskRuleTransferService {
    static func exportData(
        context: ModelContext
    ) throws -> Data {
        let descriptor = FetchDescriptor<MaskRule>(
            sortBy: [
                .init(\MaskRule.date, order: .forward)
            ]
        )
        let rules = try context.fetch(descriptor)
        return try exportData(rules: rules)
    }

    static func exportData(
        rules: [MaskRule]
    ) throws -> Data {
        let payloads = rules.map { rule in
            Payload(
                date: rule.date,
                original: rule.original,
                masked: rule.masked,
                isEnabled: rule.isEnabled
            )
        }

        let transfer = Transfer(
            version: 1,
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

        guard transfer.version == 1 else {
            throw TransferError.unsupportedVersion
        }

        let existing = try context.fetch(
            FetchDescriptor<MaskRule>()
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
                    $0.original == payload.original ||
                        $0.masked == payload.masked
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
            FetchDescriptor<MaskRule>()
        ).count

        return .init(
            insertedCount: insertedCount,
            updatedCount: updatedCount,
            totalCount: totalCount
        )
    }
}

private extension MaskRuleTransferService {
    private static func insert(
        payload: Payload,
        context: ModelContext
    ) throws {
        try MaskRule.create(
            context: context,
            date: payload.date,
            original: payload.original,
            masked: payload.masked,
            isEnabled: payload.isEnabled
        )
    }

    private static func apply(
        payload: Payload,
        to rule: MaskRule,
        context: ModelContext
    ) throws {
        try rule.update(
            context: context,
            date: payload.date,
            original: payload.original,
            masked: payload.masked,
            isEnabled: payload.isEnabled
        )
    }
}
