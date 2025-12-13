//
//  MaskingResult.swift
//
//
//  Created by Hiromu Nakano on 2025/11/23.
//

import Foundation

public struct Mapping: Identifiable, Equatable {
    public let id: UUID
    public let original: String
    public let masked: String
    public let kind: MappingKind
    public let occurrenceCount: Int

    public init(
        id: UUID = .init(),
        original: String,
        masked: String,
        kind: MappingKind,
        occurrenceCount: Int
    ) {
        self.id = id
        self.original = original
        self.masked = masked
        self.kind = kind
        self.occurrenceCount = occurrenceCount
    }
}

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
