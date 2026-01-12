//
//  MappingRuleFileCoordinator.swift
//
//
//  Created by Hiromu Nakano on 2025/11/23.
//

import Foundation
import NormleLibrary
import SwiftData

@MainActor
struct MappingRuleFileCoordinator {
    let context: ModelContext

    func exportDocument() throws -> MappingRuleExportDocument {
        let data = try MappingRuleTransferService.exportData(
            context: context
        )
        return MappingRuleExportDocument(data: data)
    }

    func loadImportData(
        from url: URL
    ) throws -> Data {
        try Data(contentsOf: url)
    }

    func applyImport(
        data: Data,
        policy: MappingRuleTransferService.ImportPolicy
    ) throws -> MappingRuleTransferService.ImportResult {
        try MappingRuleTransferService.importData(
            data,
            context: context,
            policy: policy
        )
    }
}
