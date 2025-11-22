//
//  SessionService.swift
//
//
//  Created by Hiromu Nakano on 2025/11/23.
//

import Foundation
import SwiftData

public enum SessionService {
    @discardableResult
    public static func saveSession(
        context: ModelContext,
        maskedText: String,
        note: String?,
        mappings: [Mapping]
    ) throws -> MaskingSession {
        let session = MaskingSession()
        context.insert(session)

        session.createdAt = Date()
        session.maskedText = maskedText
        session.note = note
        session.mappings = mappings.map {
            MappingRecord.create(
                context: context,
                session: session,
                mapping: $0
            )
        }

        try context.save()

        return session
    }

    @discardableResult
    public static func updateSession(
        context: ModelContext,
        session: MaskingSession,
        maskedText: String,
        note: String?,
        mappings: [Mapping]
    ) throws -> MaskingSession {
        session.createdAt = Date()
        session.maskedText = maskedText
        session.note = note

        session.mappings?.forEach(context.delete)
        session.mappings = mappings.map {
            MappingRecord.create(
                context: context,
                session: session,
                mapping: $0
            )
        }

        try context.save()

        return session
    }

    public static func deleteAll(
        context: ModelContext
    ) throws {
        let descriptor = FetchDescriptor<MaskingSession>()
        try context.fetch(descriptor).forEach(context.delete)
        try context.save()
    }

    public static func delete(
        context: ModelContext,
        session: MaskingSession
    ) throws {
        context.delete(session)
        try context.save()
    }
}

private extension MappingRecord {
    static func create(
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
