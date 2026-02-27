//
//  TransformExecutionService.swift
//
//
//  Created by Hiromu Nakano on 2026/02/27.
//

import Foundation
import SwiftData

public enum TransformExecutionError: LocalizedError {
    case pipeline(TransformPipelineError)
    case persistence(Error)

    public var errorDescription: String? {
        switch self {
        case .pipeline(let error):
            error.errorDescription
        case .persistence(let error):
            error.localizedDescription
        }
    }
}

public enum TransformExecutionService {
    public static func runAndSave(
        context: ModelContext,
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
