//
//  ManualRuleTransferService.swift
//
//
//  Created by Hiromu Nakano on 2025/11/23.
//

import Foundation
import SwiftData

public enum ManualRuleTransferService {
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
        let createdAt: Date
        let original: String
        let alias: String
        let kindID: String
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

public extension ManualRuleTransferService {
    static func exportData(
        context: ModelContext
    ) throws -> Data {
        let descriptor = FetchDescriptor<ManualRule>(
            sortBy: [
                .init(\ManualRule.createdAt, order: .forward)
            ]
        )
        let rules = try context.fetch(descriptor)
        return try exportData(rules: rules)
    }

    static func exportData(
        rules: [ManualRule]
    ) throws -> Data {
        let payloads = rules.map { rule in
            Payload(
                createdAt: rule.createdAt,
                original: rule.original,
                alias: rule.alias,
                kindID: rule.kindID,
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
            FetchDescriptor<ManualRule>()
        )

        var insertedCount = 0
        var updatedCount = 0

        switch policy {
        case .replaceAll:
            existing.forEach(context.delete)
            transfer.rules.forEach { payload in
                insert(
                    payload: payload,
                    context: context
                )
                insertedCount += 1
            }
        case .mergeExisting:
            transfer.rules.forEach { payload in
                if let match = existing.first(where: {
                    $0.original == payload.original &&
                        $0.alias == payload.alias &&
                        $0.kindID == payload.kindID
                }) {
                    apply(
                        payload: payload,
                        to: match
                    )
                    updatedCount += 1
                    return
                }

                insert(
                    payload: payload,
                    context: context
                )
                insertedCount += 1
            }
        case .appendNew:
            transfer.rules.forEach { payload in
                insert(
                    payload: payload,
                    context: context
                )
                insertedCount += 1
            }
        }

        try context.save()

        let totalCount = try context.fetch(
            FetchDescriptor<ManualRule>()
        ).count

        return .init(
            insertedCount: insertedCount,
            updatedCount: updatedCount,
            totalCount: totalCount
        )
    }
}

private extension ManualRuleTransferService {
    private static func insert(
        payload: Payload,
        context: ModelContext
    ) {
        ManualRule.create(
            context: context,
            createdAt: payload.createdAt,
            original: payload.original,
            alias: payload.alias,
            kind: MappingKind(rawValue: payload.kindID) ?? .custom,
            isEnabled: payload.isEnabled
        )
    }

    private static func apply(
        payload: Payload,
        to rule: ManualRule
    ) {
        rule.update(
            createdAt: payload.createdAt,
            original: payload.original,
            alias: payload.alias,
            kind: MappingKind(rawValue: payload.kindID) ?? .custom,
            isEnabled: payload.isEnabled
        )
    }
}
