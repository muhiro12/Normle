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
    public var uuid = UUID()
    public var createdAt = Date()
    public var original = String()
    public var alias = String()
    public var kindID = MappingKind.custom.rawValue
    public var isEnabled = true

    public init() {}
}

public extension ManualRule {
    var kind: MappingKind? {
        MappingKind(rawValue: kindID)
    }

    var maskingRule: MaskingRule {
        .init(
            id: uuid,
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
