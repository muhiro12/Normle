//
//  MappingRuleTransferCoordinator.swift
//
//
//  Created by Hiromu Nakano on 2026/02/27.
//

import Foundation
import SwiftData

public enum MappingRuleTransferCoordinator {
    public static func exportData(
        context: ModelContext
    ) throws -> Data {
        try MappingRuleTransferService.exportData(context: context)
    }

    public static func loadImportData(
        from url: URL
    ) throws -> Data {
        try Data(contentsOf: url)
    }

    public static func applyImport(
        data: Data,
        context: ModelContext,
        policy: MappingRuleTransferService.ImportPolicy
    ) throws -> MappingRuleTransferService.ImportResult {
        try MappingRuleTransferService.importData(
            data,
            context: context,
            policy: policy
        )
    }
}
