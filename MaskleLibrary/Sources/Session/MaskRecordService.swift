//
//  MaskRecordService.swift
//
//
//  Created by Hiromu Nakano on 2025/11/23.
//

import Foundation
import SwiftData

public enum MaskRecordService {
    @discardableResult
    public static func saveRecord(
        context: ModelContext,
        maskedText: String,
        mappings _: [Mapping]
    ) throws -> MaskRecord {
        let record = MaskRecord.create(
            context: context,
            maskedText: maskedText
        )

        try context.save()

        return record
    }

    @discardableResult
    public static func updateRecord(
        context: ModelContext,
        record: MaskRecord,
        maskedText: String,
        mappings _: [Mapping]
    ) throws -> MaskRecord {
        record.update(
            maskedText: maskedText
        )

        try context.save()

        return record
    }

    public static func deleteAll(
        context: ModelContext
    ) throws {
        let descriptor = FetchDescriptor<MaskRecord>()
        try context.fetch(descriptor).forEach(context.delete)
        try context.save()
    }

    public static func delete(
        context: ModelContext,
        record: MaskRecord
    ) throws {
        context.delete(record)
        try context.save()
    }
}
