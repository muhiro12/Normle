//
//  MappingListScreenModel.swift
//  Normle
//
//  Created by Codex on 2026/03/23.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import Foundation
import NormleLibrary
import Observation
import SwiftData
import TipKit

@MainActor
@Observable
final class MappingListScreenModel {
    var exportDocument = MappingRuleExportDocument(data: Data())
    var pendingImportData: Data?
    var alertTitle = String()
    var alertMessage = String()

    var isShowingAlert: Bool {
        alertMessage.isEmpty == false
    }

    func presentCreate() {
        NormleTipManager.donate(NormleTipEvents.didStartMappingCreation)
        MappingAddTip().invalidate(reason: .actionPerformed)
    }

    func prepareExport(
        context: ModelContext
    ) -> Bool {
        do {
            let data = try MappingRuleTransferCoordinator.exportData(
                context: context
            )
            exportDocument = .init(data: data)
            return true
        } catch {
            presentError(message: error.localizedDescription)
            return false
        }
    }

    func prepareImport(
        url: URL
    ) -> Bool {
        do {
            pendingImportData = try MappingRuleTransferCoordinator.loadImportData(
                from: url
            )
            return true
        } catch {
            presentError(message: error.localizedDescription)
            return false
        }
    }

    func applyImport(
        policy: MappingRuleTransferService.ImportPolicy,
        context: ModelContext
    ) async {
        guard let data = pendingImportData else {
            return
        }

        defer {
            pendingImportData = nil
        }

        do {
            let result = try await NormleMutationWorkflow.importMappings(
                data: data,
                context: context,
                policy: policy
            )
            alertTitle = String(localized: "Import completed")
            alertMessage = result.summaryLines(
                insertedText: { count in
                    String.localizedStringWithFormat(
                        String(localized: "Inserted: %d"),
                        count
                    )
                },
                updatedText: { count in
                    String.localizedStringWithFormat(
                        String(localized: "Updated: %d"),
                        count
                    )
                },
                totalText: { count in
                    String.localizedStringWithFormat(
                        String(localized: "Total: %d"),
                        count
                    )
                }
            )
            .joined(separator: "\n")
        } catch {
            presentError(message: error.localizedDescription)
        }
    }

    func clearPendingImportData() {
        pendingImportData = nil
    }

    func presentError(
        message: String
    ) {
        alertTitle = String(localized: "Error")
        alertMessage = message
    }

    func dismissAlert() {
        alertTitle = String()
        alertMessage = String()
    }
}
