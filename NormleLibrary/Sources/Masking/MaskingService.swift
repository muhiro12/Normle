//
//  MaskingService.swift
//
//
//  Created by Hiromu Nakano on 2025/11/23.
//

import Foundation

public enum MaskingService {
    public static func anonymize(
        text: String,
        maskRules: [MaskingRule],
        options: MaskingOptions
    ) -> MaskingResult {
        var workingText = text
        var mappings = [Mapping]()
        var generatedMappings = [String: Mapping]()
        var counters = [MappingKind: Int]()

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
                mappings.append(mapping)
                generatedMappings[rule.original] = mapping
            }

        if options.isURLMaskingEnabled {
            workingText = applyAutomaticMasking(
                in: workingText,
                kind: .url,
                pattern: #"(https?|ftp)://[^\s/$.?#].[^\s]*"#,
                mappings: &mappings,
                generatedMappings: &generatedMappings,
                counters: &counters
            )
        }

        if options.isEmailMaskingEnabled {
            workingText = applyAutomaticMasking(
                in: workingText,
                kind: .email,
                pattern: #"[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}"#,
                mappings: &mappings,
                generatedMappings: &generatedMappings,
                counters: &counters,
                options: [.caseInsensitive]
            )
        }

        if options.isPhoneMaskingEnabled {
            workingText = applyAutomaticMasking(
                in: workingText,
                kind: .phone,
                pattern: #"(\+\d{1,3}[\s-]?)?(\(?\d{2,4}\)?[\s-]?)?[\d\s-]{7,}"#,
                mappings: &mappings,
                generatedMappings: &generatedMappings,
                counters: &counters
            )
        }

        return .init(
            maskedText: workingText,
            mappings: mappings
        )
    }
}

private extension MaskingService {
    static func applyAutomaticMasking(
        in text: String,
        kind: MappingKind,
        pattern: String,
        mappings: inout [Mapping],
        generatedMappings: inout [String: Mapping],
        counters: inout [MappingKind: Int],
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

        uniqueMatches.forEach { original in
            guard mappings.contains(where: { $0.original == original || $0.masked == original }) == false else {
                return
            }

            let existing = generatedMappings[original]
            let masked = existing?.masked ?? "\(kind.aliasPrefix)(\(counters[kind, default: .zero] + 1))"

            let (updatedText, count) = replaceOccurrences(
                in: workingText,
                target: original,
                replacement: masked
            )

            guard count > .zero else {
                return
            }

            workingText = updatedText
            if existing == nil {
                counters[kind, default: .zero] += 1
            }

            let mapping = Mapping(
                id: existing?.id ?? UUID(),
                original: existing?.original ?? original,
                masked: masked,
                kind: kind,
                occurrenceCount: (existing?.occurrenceCount ?? .zero) + count
            )
            mappings.removeAll {
                $0.id == mapping.id
            }
            mappings.append(mapping)
            generatedMappings[mapping.original] = mapping
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
