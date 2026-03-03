//
//  MaskingService.swift
//  Normle
//
//  Created by Hiromu Nakano on 2025/11/23.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import Foundation

/// Applies manual and automatic masking rules to text.
public enum MaskingService {
    /// Returns the masked text and generated mappings for the given input.
    public static func anonymize(
        text: String,
        maskRules: [MaskingRule],
        options: MaskingOptions
    ) -> MaskingResult {
        var workingText = text
        var state = AutomaticMaskingState()

        workingText = applyManualMasking(
            text: workingText,
            maskRules: maskRules,
            state: &state
        )

        if options.isURLMaskingEnabled {
            workingText = applyAutomaticMasking(
                in: workingText,
                kind: .url,
                pattern: #"(https?|ftp)://[^\s/$.?#].[^\s]*"#,
                state: &state
            )
        }

        if options.isEmailMaskingEnabled {
            workingText = applyAutomaticMasking(
                in: workingText,
                kind: .email,
                pattern: #"[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}"#,
                state: &state,
                options: [.caseInsensitive]
            )
        }

        if options.isPhoneMaskingEnabled {
            workingText = applyAutomaticMasking(
                in: workingText,
                kind: .phone,
                pattern: #"(\+\d{1,3}[\s-]?)?(\(?\d{2,4}\)?[\s-]?)?[\d\s-]{7,}"#,
                state: &state
            )
        }

        return .init(
            maskedText: workingText,
            mappings: state.mappings
        )
    }
}

private extension MaskingService {
    struct AutomaticMaskingState {
        var mappings = [Mapping]()
        var generatedMappings = [String: Mapping]()
        var counters = [MappingKind: Int]()
    }

    static func applyManualMasking(
        text: String,
        maskRules: [MaskingRule],
        state: inout AutomaticMaskingState
    ) -> String {
        var workingText = text

        maskRules
            .filter {
                !$0.original.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
                    !$0.masked.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
                    $0.isEnabled
            }
            .forEach { rule in
                let (updatedText, count) = replaceOccurrences(
                    in: workingText,
                    target: rule.original,
                    replacement: rule.masked
                )
                guard count > .zero else {
                    return
                }
                workingText = updatedText
                let mapping = Mapping(
                    original: rule.original,
                    masked: rule.masked,
                    kind: rule.kind,
                    occurrenceCount: count
                )
                state.mappings.append(mapping)
                state.generatedMappings[rule.original] = mapping
            }

        return workingText
    }

    static func applyAutomaticMasking(
        in text: String,
        kind: MappingKind,
        pattern: String,
        state: inout AutomaticMaskingState,
        options: NSRegularExpression.Options = []
    ) -> String {
        guard let expression = try? NSRegularExpression(
            pattern: pattern,
            options: options
        ) else {
            return text
        }

        var workingText = text
        let matches = expressions(
            for: expression,
            in: workingText
        )
        let uniqueMatches = unique(strings: matches)

        for original in uniqueMatches {
            guard state.mappings.contains(
                where: { mapping in
                    mapping.original == original || mapping.masked == original
                }
            ) == false else {
                continue
            }

            let existing = state.generatedMappings[original]
            let masked = existing?.masked ??
                "\(kind.aliasPrefix)(\(state.counters[kind, default: .zero] + 1))"

            let (updatedText, count) = replaceOccurrences(
                in: workingText,
                target: original,
                replacement: masked
            )

            guard count > .zero else {
                continue
            }

            workingText = updatedText
            if existing == nil {
                state.counters[kind, default: .zero] += 1
            }

            let mapping = Mapping(
                original: existing?.original ?? original,
                masked: masked,
                kind: kind,
                occurrenceCount: (existing?.occurrenceCount ?? .zero) + count,
                id: existing?.id ?? UUID()
            )
            state.mappings.removeAll {
                $0.id == mapping.id
            }
            state.mappings.append(mapping)
            state.generatedMappings[mapping.original] = mapping
        }

        return workingText
    }

    static func replaceOccurrences(
        in text: String,
        target: String,
        replacement: String
    ) -> (String, Int) {
        let components = text.components(separatedBy: target)
        guard components.count > 1 else {
            return (text, .zero)
        }
        let updatedText = components.joined(separator: replacement)
        return (updatedText, components.count - 1)
    }

    static func expressions(
        for expression: NSRegularExpression,
        in text: String
    ) -> [String] {
        let matches = expression.matches(
            in: text,
            options: [],
            range: .init(
                location: .zero,
                length: text.utf16.count
            )
        )

        return matches.compactMap { match -> String? in
            guard let range = Range(match.range, in: text) else {
                return nil
            }
            return String(text[range])
        }
    }

    static func unique(strings: [String]) -> [String] {
        var seen = Set<String>()
        var result = [String]()
        strings.forEach { value in
            if seen.contains(value) {
                return
            }
            seen.insert(value)
            result.append(value)
        }
        return result
    }
}
