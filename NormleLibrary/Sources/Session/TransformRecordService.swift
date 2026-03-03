//
//  TransformRecordService.swift
//  Normle
//
//  Created by Hiromu Nakano on 2025/11/23.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import Foundation
import SwiftData

/// Persists transform records created by the transform pipeline.
public enum TransformRecordService {
    /// Saves a new transform record and persists the model context.
    @discardableResult
    public static func saveRecord(
        context: ModelContext,
        sourceText: String?,
        targetText: String,
        mappings: [Mapping]
    ) throws -> TransformRecord {
        let record = TransformRecord.create(
            context: context,
            sourceText: sourceText,
            targetText: targetText,
            mappings: mappings
        )

        try context.save()

        return record
    }

    /// Updates an existing transform record and persists the model context.
    @discardableResult
    public static func updateRecord(
        context: ModelContext,
        record: TransformRecord,
        sourceText: String?,
        targetText: String,
        mappings: [Mapping]
    ) throws -> TransformRecord {
        record.update(
            sourceText: sourceText,
            targetText: targetText,
            mappings: mappings
        )

        try context.save()

        return record
    }

    /// Deletes all transform records from the model context.
    public static func deleteAll(
        context: ModelContext
    ) throws {
        let descriptor = FetchDescriptor<TransformRecord>()
        try context.fetch(descriptor).forEach(context.delete)
        try context.save()
    }

    /// Deletes a specific transform record from the model context.
    public static func delete(
        context: ModelContext,
        record: TransformRecord
    ) throws {
        context.delete(record)
        try context.save()
    }
}
