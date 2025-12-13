//
//  TransformRecord.swift
//
//
//  Created by Hiromu Nakano on 2025/11/23.
//

import Foundation
import SwiftData

/// A persisted transform result entry kept in history.
@Model
public final class TransformRecord {
    public private(set) var date = Date()
    public private(set) var targetText = String()

    @Relationship(deleteRule: .nullify)
    public private(set) var tags: [Tag]?

    private init() {}

    @discardableResult
    public static func create(
        context: ModelContext,
        targetText: String
    ) -> TransformRecord {
        let record = TransformRecord()
        context.insert(record)

        record.date = Date()
        record.targetText = targetText

        return record
    }

    public func update(
        targetText: String
    ) {
        date = Date()
        self.targetText = targetText
    }
}

public extension TransformRecord {
    var previewText: String {
        if targetText.count > 80 {
            return "\(targetText.prefix(80))…"
        }
        return targetText
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
