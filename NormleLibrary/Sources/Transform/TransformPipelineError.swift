//
//  TransformPipelineError.swift
//  Normle
//
//  Created by Hiromu Nakano on 2026/03/03.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

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
