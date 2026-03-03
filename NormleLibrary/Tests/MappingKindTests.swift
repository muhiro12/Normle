//
//  MappingKindTests.swift
//  Normle
//
//  Created by Hiromu Nakano on 2026/01/06.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

@testable import NormleLibrary
import Testing

struct MappingKindTests {
    @Test
    func displayNameMatchesExpectedText() {
        let expectations: [(MappingKind, String)] = [
            (.person, "Person"),
            (.company, "Company"),
            (.project, "Project"),
            (.url, "URL"),
            (.email, "Email"),
            (.phone, "Phone"),
            (.other, "Other"),
            (.custom, "Custom")
        ]

        for (kind, expectedName) in expectations {
            #expect(kind.displayName == expectedName)
        }
    }

    @Test
    func aliasPrefixMatchesExpectedText() {
        let expectations: [(MappingKind, String)] = [
            (.person, "Person"),
            (.company, "Client"),
            (.project, "Project"),
            (.url, "PrivateURL"),
            (.email, "Email"),
            (.phone, "Phone"),
            (.other, "Alias"),
            (.custom, "Alias")
        ]

        for (kind, expectedPrefix) in expectations {
            #expect(kind.aliasPrefix == expectedPrefix)
        }
    }
}
