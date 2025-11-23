//
//  ManualRule.swift
//
//
//  Created by Hiromu Nakano on 2025/11/23.
//

import Foundation
import SwiftData

/// A persisted manual mapping rule configured by the user.
@Model
public final class ManualRule {
    public private(set) var createdAt = Date()
    public private(set) var original = String()
    public private(set) var alias = String()
    public private(set) var kindID = MappingKind.custom.rawValue
    public private(set) var isEnabled = true

    private init() {}

    @discardableResult
    public static func create(
        context: ModelContext,
        createdAt: Date = Date(),
        original: String,
        alias: String,
        kind: MappingKind = .custom,
        isEnabled: Bool = true
    ) -> ManualRule {
        let rule = ManualRule()
        context.insert(rule)

        rule.createdAt = createdAt
        rule.original = original
        rule.alias = alias
        rule.kindID = kind.rawValue
        rule.isEnabled = isEnabled

        return rule
    }

    public func update(
        createdAt: Date? = nil,
        original: String,
        alias: String,
        kind: MappingKind,
        isEnabled: Bool
    ) {
        if let createdAt {
            self.createdAt = createdAt
        }
        self.original = original
        self.alias = alias
        kindID = kind.rawValue
        self.isEnabled = isEnabled
    }
}

public extension ManualRule {
    var kind: MappingKind? {
        MappingKind(rawValue: kindID)
    }

    var maskingRule: MaskingRule {
        let identifier = persistentModelID.base64String
        return .init(
            id: identifier,
            original: original,
            alias: alias,
            kind: kind ?? .custom,
            createdAt: createdAt,
            isEnabled: isEnabled
        )
    }
}

extension ManualRule: Hashable {
    public static func == (lhs: ManualRule, rhs: ManualRule) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

private extension PersistentIdentifier {
    var base64String: String {
        guard let data = try? JSONEncoder().encode(self) else {
            return UUID().uuidString
        }
        return data.base64EncodedString()
    }
}
