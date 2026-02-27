//
//  MaskingResult.swift
//
//
//  Created by Hiromu Nakano on 2025/11/23.
//

import Foundation

public struct Mapping: Identifiable, Codable, Equatable {
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

    enum CodingKeys: String, CodingKey {
        case id
        case original
        case masked
        case kind
        case occurrenceCount
        case source
        case target
        case count
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? .init()

        if let decodedOriginal = try container.decodeIfPresent(String.self, forKey: .original) {
            original = decodedOriginal
        } else {
            original = try container.decode(String.self, forKey: .source)
        }

        if let decodedMasked = try container.decodeIfPresent(String.self, forKey: .masked) {
            masked = decodedMasked
        } else {
            masked = try container.decode(String.self, forKey: .target)
        }

        kind = try container.decodeIfPresent(MappingKind.self, forKey: .kind) ?? .other
        occurrenceCount = try container.decodeIfPresent(Int.self, forKey: .occurrenceCount)
            ?? container.decodeIfPresent(Int.self, forKey: .count)
            ?? 1
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(original, forKey: .original)
        try container.encode(masked, forKey: .masked)
        try container.encode(kind, forKey: .kind)
        try container.encode(occurrenceCount, forKey: .occurrenceCount)
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
