//
//  MappingCodableTests.swift
//  Normle
//
//  Created by Codex on 2026/05/11.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import Foundation
@testable import NormleLibrary
import Testing

struct MappingCodableTests {
    @Test
    func encodeAndDecodeRoundTripsCurrentContract() throws {
        let identifier = try #require(
            UUID(uuidString: "11111111-2222-3333-4444-555555555555")
        )
        let mapping = Mapping(
            original: "Alice",
            masked: "Person A",
            kind: .person,
            occurrenceCount: 3,
            id: identifier
        )

        let data = try JSONEncoder().encode(mapping)
        let decoded = try JSONDecoder().decode(
            Mapping.self,
            from: data
        )

        #expect(decoded == mapping)
    }
}
