//
//  MappingRule.swift
//  Normle
//
//  Created by Hiromu Nakano on 2025/11/23.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import Foundation
import SwiftData

/// A persisted manual mapping rule configured by the user.
@Model
public final class MappingRule {
    /// The last updated date of the mapping rule.
    public private(set) var date = Date()
    /// The source text to match.
    public private(set) var source = String()
    /// The replacement text to apply.
    public private(set) var target = String()
    /// Indicates whether the rule is active.
    public private(set) var isEnabled = true

    /// Tags associated with the mapping rule.
    @Relationship(deleteRule: .nullify)
    public private(set) var tags = [Tag]()

    private init() {
        // Required for SwiftData model creation.
    }

    /// Creates a new mapping rule after validating source and target uniqueness.
    @discardableResult
    public static func create(
        context: ModelContext,
        source: String,
        target: String,
        isEnabled: Bool = true,
        date: Date = Date()
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

    /// Updates the mapping rule after validating source and target uniqueness.
    public func update(
        context: ModelContext,
        source: String,
        target: String,
        isEnabled: Bool,
        date: Date? = nil
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
    /// Returns the masking rule representation of this mapping rule.
    var maskingRule: MaskingRule {
        let identifier = persistentModelID.base64String
        return .init(
            original: source,
            masked: target,
            kind: .custom,
            date: date,
            isEnabled: isEnabled,
            id: identifier
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
