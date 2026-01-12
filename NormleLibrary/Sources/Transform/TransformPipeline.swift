//
//  TransformPipeline.swift
//
//
//  Created by Hiromu Nakano on 2025/11/23.
//

import CoreGraphics
import Foundation

public enum TransformPipelineError: LocalizedError, Equatable {
    case missingImageData
    case baseTransform(BaseTransformError)

    public var errorDescription: String? {
        switch self {
        case .missingImageData:
            "Select an image to decode."
        case .baseTransform(let error):
            error.errorDescription
        }
    }
}

public struct TransformPipelineResult {
    public let outputText: String
    public let qrImage: CGImage?
    public let recordSourceText: String?
    public let recordTargetText: String

    public init(
        outputText: String,
        qrImage: CGImage?,
        recordSourceText: String?,
        recordTargetText: String
    ) {
        self.outputText = outputText
        self.qrImage = qrImage
        self.recordSourceText = recordSourceText
        self.recordTargetText = recordTargetText
    }
}

public struct TransformPipeline {
    public init() {}

    public func run(
        sourceText: String,
        presets: [TransformPreset],
        maskRules: [MaskingRule],
        options: MaskingOptions,
        imageData: Data?
    ) -> Result<TransformPipelineResult, TransformPipelineError> {
        if presets.contains(.qrEncode) {
            switch BaseTransform.qrEncode.qrCodeImage(for: sourceText) {
            case .success(let image):
                return .success(
                    .init(
                        outputText: String(),
                        qrImage: image,
                        recordSourceText: sourceText,
                        recordTargetText: String()
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
            switch BaseTransform.qrDecode.apply(text: String(), imageData: imageData) {
            case .success(let output):
                return .success(
                    .init(
                        outputText: output,
                        qrImage: nil,
                        recordSourceText: nil,
                        recordTargetText: output
                    )
                )
            case .failure(let error):
                return .failure(.baseTransform(error))
            }
        }

        var outputText = sourceText
        for preset in presets {
            switch preset {
            case .builtIn(let transform):
                let result = transform.apply(text: outputText)
                switch result {
                case .success(let transformedText):
                    outputText = transformedText
                case .failure(let error):
                    return .failure(.baseTransform(error))
                }
            case .customMapping:
                let masked = MaskingService.anonymize(
                    text: outputText,
                    maskRules: maskRules,
                    options: options
                )
                outputText = masked.maskedText
            }
        }
        return .success(
            .init(
                outputText: outputText,
                qrImage: nil,
                recordSourceText: sourceText,
                recordTargetText: outputText
            )
        )
    }
}
