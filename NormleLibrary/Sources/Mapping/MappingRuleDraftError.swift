//
//  MappingRuleDraftError.swift
//  Normle
//
//  Created by Hiromu Nakano on 2026/03/03.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import Foundation

public enum MappingRuleDraftError: LocalizedError, Equatable {
    case missingSource
    case missingTarget

    public var errorDescription: String? {
        switch self {
        case .missingSource:
            "Enter a source text."
        case .missingTarget:
            "Enter a target text."
        }
    }
}
