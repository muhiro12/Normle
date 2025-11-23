//
//  MappingRecord.swift
//
//
//  Created by Hiromu Nakano on 2025/11/23.
//

import Foundation
import SwiftData

/// A persisted mapping entry linking an original string to its alias.
@Model
public final class MappingRecord {
    public private(set) var original = String()
    public private(set) var alias = String()
    public private(set) var kindID = String()
    public private(set) var occurrenceCount = Int.zero

    @Relationship(inverse: \MaskingSession.mappings)
    public private(set) var session: MaskingSession?

    private init() {}

    @discardableResult
    public static func create(
        context: ModelContext,
        session: MaskingSession,
        mapping: Mapping
    ) -> MappingRecord {
        let record = MappingRecord()
        context.insert(record)

        record.original = mapping.original
        record.alias = mapping.alias
        record.kindID = mapping.kind.rawValue
        record.occurrenceCount = mapping.occurrenceCount
        record.session = session

        return record
    }
}

public extension MappingRecord {
    var kind: MappingKind? {
        MappingKind(rawValue: kindID)
    }
}
