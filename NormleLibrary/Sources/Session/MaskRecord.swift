//
//  MaskRecord.swift
//
//
//  Created by Hiromu Nakano on 2025/11/23.
//

import Foundation
import SwiftData

/// A persisted mask result entry kept in history.
@Model
public final class MaskRecord {
    public private(set) var date = Date()
    public private(set) var maskedText = String()

    @Relationship(deleteRule: .nullify)
    public private(set) var tags: [Tag]?

    private init() {}

    @discardableResult
    public static func create(
        context: ModelContext,
        maskedText: String
    ) -> MaskRecord {
        let record = MaskRecord()
        context.insert(record)

        record.date = Date()
        record.maskedText = maskedText

        return record
    }

    public func update(
        maskedText: String
    ) {
        date = Date()
        self.maskedText = maskedText
    }
}

public extension MaskRecord {
    var previewText: String {
        if maskedText.count > 80 {
            return "\(maskedText.prefix(80))…"
        }
        return maskedText
    }
}

extension MaskRecord: Hashable {
    public static func == (lhs: MaskRecord, rhs: MaskRecord) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
