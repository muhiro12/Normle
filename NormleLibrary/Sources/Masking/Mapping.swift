//
//  Mapping.swift
//  Normle
//
//  Created by Hiromu Nakano on 2026/03/03.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import Foundation

public struct Mapping: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public let original: String
    public let masked: String
    public let kind: MappingKind
    public let occurrenceCount: Int

    public init(
        original: String,
        masked: String,
        kind: MappingKind,
        occurrenceCount: Int,
        id: UUID = .init()
    ) {
        self.id = id
        self.original = original
        self.masked = masked
        self.kind = kind
        self.occurrenceCount = occurrenceCount
    }
}
