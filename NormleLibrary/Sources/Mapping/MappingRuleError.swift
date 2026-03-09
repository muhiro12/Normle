//
//  MappingRuleError.swift
//  Normle
//
//  Created by Hiromu Nakano on 2026/03/03.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import Foundation

public enum MappingRuleError: LocalizedError {
    case duplicateSource
    case duplicateTarget

    public var errorDescription: String? {
        switch self {
        case .duplicateSource:
            "The source text is already registered."
        case .duplicateTarget:
            "The target text is already registered."
        }
    }
}
