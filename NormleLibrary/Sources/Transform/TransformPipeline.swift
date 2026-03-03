//
//  TransformPipeline.swift
//  Normle
//
//  Created by Hiromu Nakano on 2025/11/23.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import CoreGraphics
import Foundation

/// Applies the selected transform presets to source text.
public struct TransformPipeline {
    /// Creates a transform pipeline.
    public init() {}

    /// Runs the selected presets and returns either a pipeline result or an error.
    public func run(
        sourceText: String,
        presets: [TransformPreset],
        maskRules: [MaskingRule],
        options: MaskingOptions,
        imageData: Data?
    ) -> Result<TransformPipelineResult, TransformPipelineError> {
        if let qrResult = qrResultIfNeeded(
            sourceText: sourceText,
            presets: presets,
            imageData: imageData
        ) {
            return qrResult
        }

        return runStandardPresets(
            sourceText: sourceText,
            presets: presets,
            maskRules: maskRules,
            options: options
        )
    }
}

private extension TransformPipeline {
    struct TransformState {
        var outputText: String
        var mappings: [Mapping]
    }

    func qrResultIfNeeded(
        sourceText: String,
        presets: [TransformPreset],
        imageData: Data?
    ) -> Result<TransformPipelineResult, TransformPipelineError>? {
        if presets.contains(.qrEncode) {
            switch BaseTransform.qrEncode.qrCodeImage(for: sourceText) {
            case .success(let image):
                return .success(
                    .init(
                        outputText: String(),
                        qrImage: image,
                        recordSourceText: sourceText,
                        recordTargetText: String(),
                        mappings: []
                    )
                )
            case .failure(let error):
                return .failure(.baseTransform(error))
            }
        }

        if presets.contains(.qrDecode) {
            guard let imageData else {
                return .failure(.missingImageData)
            }

            switch BaseTransform.qrDecode.apply(
                text: String(),
                imageData: imageData
            ) {
            case .success(let output):
                return .success(
                    .init(
                        outputText: output,
                        qrImage: nil,
                        recordSourceText: nil,
                        recordTargetText: output,
                        mappings: []
                    )
                )
            case .failure(let error):
                return .failure(.baseTransform(error))
            }
        }

        return nil
    }

    func runStandardPresets(
        sourceText: String,
        presets: [TransformPreset],
        maskRules: [MaskingRule],
        options: MaskingOptions
    ) -> Result<TransformPipelineResult, TransformPipelineError> {
        var state = TransformState(
            outputText: sourceText,
            mappings: []
        )

        for preset in presets {
            switch preset {
            case .builtIn(let transform):
                switch applyBuiltInTransform(
                    transform,
                    state: state
                ) {
                case .success(let updatedState):
                    state = updatedState
                case .failure(let error):
                    return .failure(error)
                }
            case .customMapping:
                let masked = MaskingService.anonymize(
                    text: state.outputText,
                    maskRules: maskRules,
                    options: options
                )
                state.outputText = masked.maskedText
                state.mappings = masked.mappings
            }
        }

        return .success(
            .init(
                outputText: state.outputText,
                qrImage: nil,
                recordSourceText: sourceText,
                recordTargetText: state.outputText,
                mappings: state.mappings
            )
        )
    }

    func applyBuiltInTransform(
        _ transform: BaseTransform,
        state: TransformState
    ) -> Result<TransformState, TransformPipelineError> {
        switch transform.apply(text: state.outputText) {
        case .success(let transformedText):
            var updatedState = TransformState(
                outputText: transformedText,
                mappings: state.mappings
            )
            guard state.mappings.isEmpty == false else {
                return .success(updatedState)
            }

            switch transformedMappings(
                state.mappings,
                using: transform
            ) {
            case .success(let transformedMappings):
                updatedState.mappings = transformedMappings
                return .success(updatedState)
            case .failure(let error):
                return .failure(.baseTransform(error))
            }
        case .failure(let error):
            return .failure(.baseTransform(error))
        }
    }

    func transformedMappings(
        _ mappings: [Mapping],
        using transform: BaseTransform
    ) -> Result<[Mapping], BaseTransformError> {
        var transformedMappings = [Mapping]()
        for mapping in mappings {
            switch transform.apply(text: mapping.masked) {
            case .success(let transformedMaskedText):
                transformedMappings.append(
                    .init(
                        original: mapping.original,
                        masked: transformedMaskedText,
                        kind: mapping.kind,
                        occurrenceCount: mapping.occurrenceCount,
                        id: mapping.id
                    )
                )
            case .failure(let error):
                return .failure(error)
            }
        }
        return .success(transformedMappings)
    }
}
