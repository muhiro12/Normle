//
//  MappingRuleTransferCoordinator.swift
//  Normle
//
//  Created by Hiromu Nakano on 2026/02/27.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import Foundation
import SwiftData

/// Coordinates mapping rule import and export operations for the app layer.
public enum MappingRuleTransferCoordinator {
    /// Exports mapping rules from the provided model context.
    public static func exportData(
        context: ModelContext
    ) throws -> Data {
        try MappingRuleTransferService.exportData(context: context)
    }

    /// Loads raw import data from a selected file URL.
    public static func loadImportData(
        from url: URL
    ) throws -> Data {
        try Data(contentsOf: url)
    }

    /// Applies imported mapping rules using the selected policy.
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
