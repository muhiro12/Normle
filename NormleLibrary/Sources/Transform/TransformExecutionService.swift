//
//  TransformExecutionService.swift
//  Normle
//
//  Created by Hiromu Nakano on 2026/02/27.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import Foundation
import SwiftData

/// Runs a transform pipeline and persists successful results.
public struct TransformExecutionService {
    private let context: ModelContext

    /// Creates a transform execution service for the provided model context.
    public init(context: ModelContext) {
        self.context = context
    }

    /// Runs the pipeline and saves the resulting transform record on success.
    public func runAndSave(
        sourceText: String,
        presets: [TransformPreset],
        maskRules: [MaskingRule],
        options: MaskingOptions,
        imageData: Data?
    ) -> Result<TransformPipelineResult, TransformExecutionError> {
        let pipeline = TransformPipeline()
        let pipelineResult = pipeline.run(
            sourceText: sourceText,
            presets: presets,
            maskRules: maskRules,
            options: options,
            imageData: imageData
        )

        switch pipelineResult {
        case .success(let output):
            do {
                _ = try TransformRecordService.saveRecord(
                    context: context,
                    sourceText: output.recordSourceText,
                    targetText: output.recordTargetText,
                    mappings: output.mappings
                )
                return .success(output)
            } catch {
                return .failure(.persistence(error))
            }
        case .failure(let error):
            return .failure(.pipeline(error))
        }
    }
}
