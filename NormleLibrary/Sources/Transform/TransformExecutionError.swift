//
//  TransformExecutionError.swift
//  Normle
//
//  Created by Hiromu Nakano on 2026/03/03.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import Foundation

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
