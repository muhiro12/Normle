//
//  MappingRule.swift
//
//
//  Created by Hiromu Nakano on 2025/11/23.
//

import Foundation
import SwiftData

public enum MappingRuleError: LocalizedError {
    case duplicateSource
    case duplicateTarget

    public var errorDescription: String? {
        switch self {
        case .duplicateSource:
            "The source text is already registered."
        case .duplicateTarget:
            "The target text is already registered."
        }
    }
}

/// A persisted manual mapping rule configured by the user.
@Model
public final class MappingRule {
    public private(set) var date = Date()
    public private(set) var source = String()
    public private(set) var target = String()
    public private(set) var isEnabled = true

    @Relationship(deleteRule: .nullify)
    public private(set) var tags: [Tag]?

    private init() {}

    @discardableResult
    public static func create(
        context: ModelContext,
        date: Date = Date(),
        source: String,
        target: String,
        isEnabled: Bool = true
    ) throws -> MappingRule {
        try validateUniqueness(
            context: context,
            source: source,
            target: target,
            excluding: nil
        )

        let rule = MappingRule()
        context.insert(rule)

        rule.date = date
        rule.source = source
        rule.target = target
        rule.isEnabled = isEnabled

        return rule
    }

    public func update(
        context: ModelContext,
        date: Date? = nil,
        source: String,
        target: String,
        isEnabled: Bool
    ) throws {
        try Self.validateUniqueness(
            context: context,
            source: source,
            target: target,
            excluding: self
        )

        if let date {
            self.date = date
        }
        self.source = source
        self.target = target
        self.isEnabled = isEnabled
    }
}

public extension MappingRule {
    var maskingRule: MaskingRule {
        let identifier = persistentModelID.base64String
        return .init(
            id: identifier,
            original: source,
            masked: target,
            kind: .custom,
            date: date,
            isEnabled: isEnabled
        )
    }
}

extension MappingRule: Hashable {
    public static func == (lhs: MappingRule, rhs: MappingRule) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

private extension PersistentIdentifier {
    var base64String: String {
        do {
            let data = try JSONEncoder().encode(self)
            return data.base64EncodedString()
        } catch {
            assertionFailure(error.localizedDescription)
            return String(describing: self)
        }
    }
}

private extension MappingRule {
    static func validateUniqueness(
        context: ModelContext,
        source: String,
        target: String,
        excluding rule: MappingRule?
    ) throws {
        let descriptor = FetchDescriptor<MappingRule>(
            predicate: #Predicate<MappingRule> { candidate in
                candidate.source == source || candidate.target == target
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

        if conflict.source == source {
            throw MappingRuleError.duplicateSource
        }

        if conflict.target == target {
            throw MappingRuleError.duplicateTarget
        }
    }
}
