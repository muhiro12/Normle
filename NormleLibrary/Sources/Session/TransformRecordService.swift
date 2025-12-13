//
//  TransformRecordService.swift
//
//
//  Created by Hiromu Nakano on 2025/11/23.
//

import Foundation
import SwiftData

public enum TransformRecordService {
    @discardableResult
    public static func saveRecord(
        context: ModelContext,
        targetText: String,
        mappings _: [Mapping]
    ) throws -> TransformRecord {
        let record = TransformRecord.create(
            context: context,
            targetText: targetText
        )

        try context.save()

        return record
    }

    @discardableResult
    public static func updateRecord(
        context: ModelContext,
        record: TransformRecord,
        targetText: String,
        mappings _: [Mapping]
    ) throws -> TransformRecord {
        record.update(
            targetText: targetText
        )

        try context.save()

        return record
    }

    public static func deleteAll(
        context: ModelContext
    ) throws {
        let descriptor = FetchDescriptor<TransformRecord>()
        try context.fetch(descriptor).forEach(context.delete)
        try context.save()
    }

    public static func delete(
        context: ModelContext,
        record: TransformRecord
    ) throws {
        context.delete(record)
        try context.save()
    }
}
