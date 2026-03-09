//
//  TransformRecord.swift
//  Normle
//
//  Created by Hiromu Nakano on 2025/11/23.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import Foundation
import SwiftData

/// A persisted mapping transform entry kept in history, pairing source and target texts.
/// When `sourceText` is nil, it represents an intentional decision not to retain the input text for security.
@Model
public final class TransformRecord {
    /// The creation or last update date of the record.
    public private(set) var date = Date()
    /// The retained original text, if the source text is allowed to be stored.
    public private(set) var sourceText: String?
    /// The transformed text stored in history.
    public private(set) var targetText = String()
    /// The encoded mapping list associated with this record.
    public private(set) var mappingsData = Data()

    /// Tags associated with the transform record.
    @Relationship(deleteRule: .nullify)
    public private(set) var tags = [Tag]()

    private init() {}

    /// Creates and inserts a transform record into the provided model context.
    @discardableResult
    public static func create(
        context: ModelContext,
        sourceText: String?,
        targetText: String,
        mappings: [Mapping] = []
    ) -> TransformRecord {
        let record = TransformRecord()
        context.insert(record)

        record.date = Date()
        record.sourceText = sourceText
        record.targetText = targetText
        record.mappingsData = encodeMappings(mappings)

        return record
    }

    /// Updates the stored text and mappings for the record.
    public func update(
        sourceText: String?,
        targetText: String,
        mappings: [Mapping] = []
    ) {
        date = Date()
        self.sourceText = sourceText
        self.targetText = targetText
        mappingsData = Self.encodeMappings(mappings)
    }
}

public extension TransformRecord {
    /// Decodes the mappings stored with the record.
    var mappings: [Mapping] {
        Self.decodeMappings(from: mappingsData)
    }

    /// Returns the retained source text when it is non-empty.
    var retainedSourceText: String? {
        guard let sourceText,
              sourceText.isEmpty == false else {
            return nil
        }
        return sourceText
    }

    /// Returns a shortened preview of the stored target text.
    var previewText: String {
        if targetText.count > 80 {
            return "\(targetText.prefix(80))…"
        }
        return targetText
    }
}

private extension TransformRecord {
    static func encodeMappings(_ mappings: [Mapping]) -> Data {
        (try? JSONEncoder().encode(mappings)) ?? Data()
    }

    static func decodeMappings(from data: Data) -> [Mapping] {
        guard data.isEmpty == false else {
            return []
        }
        return (try? JSONDecoder().decode([Mapping].self, from: data)) ?? []
    }
}

extension TransformRecord: Hashable {
    public static func == (lhs: TransformRecord, rhs: TransformRecord) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
