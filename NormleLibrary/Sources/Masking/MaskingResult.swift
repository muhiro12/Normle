//
//  MaskingResult.swift
//  Normle
//
//  Created by Hiromu Nakano on 2025/11/23.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

public struct MaskingResult: Equatable {
    public let maskedText: String
    public let mappings: [Mapping]

    public init(
        maskedText: String,
        mappings: [Mapping]
    ) {
        self.maskedText = maskedText
        self.mappings = mappings
    }
}
