//
//  NormleMutationWorkflow.swift
//  Normle
//
//  Created by Codex on 2026/03/10.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import Foundation
import MHMutationFlow
import MHReviewPolicy
import NormleLibrary
import SwiftData

enum NormleMutationWorkflow {
    private enum MutationName {
        static let transform = "runTransform"
        static let createMapping = "createMapping"
        static let updateMapping = "updateMapping"
        static let deleteMapping = "deleteMapping"
        static let importMappings = "importMappings"
        static let deleteHistory = "deleteHistory"
        static let deleteAllHistory = "deleteAllHistory"
    }

    struct TransformRequest: Sendable {
        let sourceText: String
        let presets: [TransformPreset]
        let maskRules: [MaskingRule]
        let options: MaskingOptions
        let imageData: Data?
    }

    @MainActor
    static func runTransform(
        context: ModelContext,
        request: TransformRequest
    ) async throws -> TransformPipelineResult {
        try await run(
            name: MutationName.transform,
            source: #fileID
        ) {
            let result = TransformExecutionService(context: context).runAndSave(
                sourceText: request.sourceText,
                presets: request.presets,
                maskRules: request.maskRules,
                options: request.options,
                imageData: request.imageData
            )

            switch result {
            case .success(let output):
                return output
            case .failure(let error):
                throw error
            }
        }
    }

    @MainActor
    static func saveMapping(
        context: ModelContext,
        draft: MappingRuleDraft,
        rule: MappingRule?
    ) async throws {
        _ = try await run(
            name: rule == nil ? MutationName.createMapping : MutationName.updateMapping,
            source: #fileID
        ) {
            try draft.apply(
                context: context,
                to: rule
            )
            return ()
        }
    }

    @MainActor
    static func deleteMapping(
        context: ModelContext,
        rule: MappingRule
    ) async throws {
        _ = try await run(
            name: MutationName.deleteMapping,
            source: #fileID
        ) {
            context.delete(rule)
            try context.save()
            return ()
        }
    }

    @MainActor
    static func importMappings(
        data: Data,
        context: ModelContext,
        policy: MappingRuleTransferService.ImportPolicy
    ) async throws -> MappingRuleTransferService.ImportResult {
        try await run(
            name: MutationName.importMappings,
            source: #fileID
        ) {
            try MappingRuleTransferCoordinator.applyImport(
                data: data,
                context: context,
                policy: policy
            )
        }
    }

    @MainActor
    static func deleteHistory(
        context: ModelContext,
        record: TransformRecord
    ) async throws {
        _ = try await run(
            name: MutationName.deleteHistory,
            source: #fileID
        ) {
            try TransformRecordService.delete(
                context: context,
                record: record
            )
            return ()
        }
    }

    @MainActor
    static func deleteAllHistory(
        context: ModelContext
    ) async throws {
        _ = try await run(
            name: MutationName.deleteAllHistory,
            source: #fileID
        ) {
            try TransformRecordService.deleteAll(
                context: context
            )
            return ()
        }
    }
}

private extension NormleMutationWorkflow {
    @MainActor
    static func run<ResultValue: Sendable>(
        name: String,
        source: String,
        operation: @escaping @MainActor @Sendable () throws -> ResultValue
    ) async throws -> ResultValue {
        try await MHMutationWorkflow.runThrowing(
            name: name,
            operation: operation,
            adapter: reviewAdapter(source: source),
            adapterValue: ()
        )
    }

    static func reviewAdapter(
        source: String
    ) -> MHMutationAdapter<Void> {
        let reviewFlow = NormleReviewSupport.flow(
            context: .mutation,
            source: source
        )

        return .fixed(
            [
                reviewFlow.step(name: "scheduleReviewRequest")
            ]
        )
    }
}
