//
//  TransformPipelineResult.swift
//  Normle
//
//  Created by Hiromu Nakano on 2026/03/03.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import CoreGraphics

/// Describes the output produced by a transform pipeline run.
public struct TransformPipelineResult: Sendable {
    /// The transformed output text.
    public let outputText: String
    /// The generated QR image, when the pipeline performs QR encoding.
    public let qrImage: CGImage?
    /// The source text that should be stored in history.
    public let recordSourceText: String?
    /// The target text that should be stored in history.
    public let recordTargetText: String
    /// The mappings produced during masking.
    public let mappings: [Mapping]

    /// Creates a transform pipeline result.
    public init(
        outputText: String,
        qrImage: CGImage?,
        recordSourceText: String?,
        recordTargetText: String,
        mappings: [Mapping]
    ) {
        self.outputText = outputText
        self.qrImage = qrImage
        self.recordSourceText = recordSourceText
        self.recordTargetText = recordTargetText
        self.mappings = mappings
    }
}
