//
//  HistoryDeletionService.swift
//
//
//  Created by Hiromu Nakano on 2025/11/23.
//

import Foundation
import NormleLibrary
import SwiftData

@MainActor
enum HistoryDeletionService {
    static func deleteAll(
        context: ModelContext
    ) {
        do {
            try TransformRecordService.deleteAll(context: context)
        } catch {
            assertionFailure(error.localizedDescription)
        }
    }

    static func delete(
        record: TransformRecord,
        context: ModelContext
    ) {
        do {
            try TransformRecordService.delete(
                context: context,
                record: record
            )
        } catch {
            assertionFailure(error.localizedDescription)
        }
    }
}
