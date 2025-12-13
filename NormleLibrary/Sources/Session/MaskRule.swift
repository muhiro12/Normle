//
//  MaskRule.swift
//
//
//  Created by Hiromu Nakano on 2025/11/23.
//

import Foundation
import SwiftData

public enum MaskRuleError: LocalizedError {
    case duplicateOriginal
    case duplicateMasked

    public var errorDescription: String? {
        switch self {
        case .duplicateOriginal:
            "The original text is already registered."
        case .duplicateMasked:
            "The masked text is already registered."
        }
    }
}

/// A persisted manual mapping rule configured by the user.
@Model
public final class MaskRule {
    public private(set) var date = Date()
    public private(set) var original = String()
    public private(set) var masked = String()
    public private(set) var isEnabled = true

    @Relationship(deleteRule: .nullify)
    public private(set) var tags: [Tag]?

    private init() {}

    @discardableResult
    public static func create(
        context: ModelContext,
        date: Date = Date(),
        original: String,
        masked: String,
        isEnabled: Bool = true
    ) throws -> MaskRule {
        try validateUniqueness(
            context: context,
            original: original,
            masked: masked,
            excluding: nil
        )

        let rule = MaskRule()
        context.insert(rule)

        rule.date = date
        rule.original = original
        rule.masked = masked
        rule.isEnabled = isEnabled

        return rule
    }

    public func update(
        context: ModelContext,
        date: Date? = nil,
        original: String,
        masked: String,
        isEnabled: Bool
    ) throws {
        try Self.validateUniqueness(
            context: context,
            original: original,
            masked: masked,
            excluding: self
        )

        if let date {
            self.date = date
        }
        self.original = original
        self.masked = masked
        self.isEnabled = isEnabled
    }
}

public extension MaskRule {
    var maskingRule: MaskingRule {
        let identifier = persistentModelID.base64String
        return .init(
            id: identifier,
            original: original,
            masked: masked,
            kind: .custom,
            date: date,
            isEnabled: isEnabled
        )
    }
}

extension MaskRule: Hashable {
    public static func == (lhs: MaskRule, rhs: MaskRule) -> Bool {
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

private extension MaskRule {
    static func validateUniqueness(
        context: ModelContext,
        original: String,
        masked: String,
        excluding rule: MaskRule?
    ) throws {
        let descriptor = FetchDescriptor<MaskRule>(
            predicate: #Predicate<MaskRule> { candidate in
                candidate.original == original || candidate.masked == masked
            }
        )
        let conflicts = try context.fetch(descriptor).filter { candidate in
            guard let rule else {
                return true
            }
            return candidate.persistentModelID != rule.persistentModelID
        }

        guard let conflict = conflicts.first else {
            return
        }

        if conflict.original == original {
            throw MaskRuleError.duplicateOriginal
        }

        if conflict.masked == masked {
            throw MaskRuleError.duplicateMasked
        }
    }
}
