//
//  MappingRuleDraft.swift
//
//
//  Created by Hiromu Nakano on 2025/11/23.
//

import Foundation
import SwiftData

public enum MappingRuleDraftError: LocalizedError, Equatable {
    case missingSource
    case missingTarget

    public var errorDescription: String? {
        switch self {
        case .missingSource:
            "Enter a source text."
        case .missingTarget:
            "Enter a target text."
        }
    }
}

public struct MappingRuleDraft: Equatable {
    public var sourceText: String
    public var targetText: String
    public var isEnabled: Bool

    public init(
        sourceText: String = String(),
        targetText: String = String(),
        isEnabled: Bool = true
    ) {
        self.sourceText = sourceText
        self.targetText = targetText
        self.isEnabled = isEnabled
    }

    public init(rule: MappingRule) {
        sourceText = rule.source
        targetText = rule.target
        isEnabled = rule.isEnabled
    }

    public var canSave: Bool {
        normalizedSourceText.isEmpty == false && normalizedTargetText.isEmpty == false
    }

    public var normalizedSourceText: String {
        sourceText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    public var normalizedTargetText: String {
        targetText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    @discardableResult
    public func apply(
        context: ModelContext,
        to rule: MappingRule?
    ) throws -> MappingRule {
        let source = normalizedSourceText
        guard source.isEmpty == false else {
            throw MappingRuleDraftError.missingSource
        }
        let target = normalizedTargetText
        guard target.isEmpty == false else {
            throw MappingRuleDraftError.missingTarget
        }

        if let rule {
            try rule.update(
                context: context,
                source: source,
                target: target,
                isEnabled: isEnabled
            )
            return rule
        }

        return try MappingRule.create(
            context: context,
            source: source,
            target: target,
            isEnabled: isEnabled
        )
    }
}
