//
//  MaskingSession.swift
//
//
//  Created by Hiromu Nakano on 2025/11/23.
//

import Foundation
import SwiftData

/// A persisted anonymization run with associated mapping records.
@Model
public final class MaskingSession {
    public private(set) var createdAt = Date()
    public private(set) var maskedText = String()
    public private(set) var note: String?

    @Relationship(deleteRule: .cascade)
    public private(set) var mappings: [MappingRecord]?

    private init() {}

    @discardableResult
    public static func create(
        context: ModelContext,
        maskedText: String,
        note: String?
    ) -> MaskingSession {
        let session = MaskingSession()
        context.insert(session)

        session.createdAt = Date()
        session.maskedText = maskedText
        session.note = note

        return session
    }

    public func update(
        maskedText: String,
        note: String?
    ) {
        createdAt = Date()
        self.maskedText = maskedText
        self.note = note
    }

    public func replaceMappings(
        with records: [MappingRecord]
    ) {
        mappings = records
    }
}

public extension MaskingSession {
    var mappingCount: Int {
        mappings?.count ?? .zero
    }

    var previewText: String {
        if maskedText.count > 80 {
            return "\(maskedText.prefix(80))…"
        }
        return maskedText
    }
}

extension MaskingSession: Hashable {
    public static func == (lhs: MaskingSession, rhs: MaskingSession) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
