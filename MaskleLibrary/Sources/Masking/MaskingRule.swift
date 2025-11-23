//
//  MaskingRule.swift
//
//
//  Created by Hiromu Nakano on 2025/11/23.
//

import Foundation
import SwiftData

public struct MaskingRule: Identifiable, Equatable {
    public let id: String
    public var original: String
    public var alias: String
    public var kind: MappingKind
    public var createdAt: Date
    public var isEnabled: Bool

    public init(
        id: String = UUID().uuidString,
        original: String,
        alias: String,
        kind: MappingKind,
        createdAt: Date = .now,
        isEnabled: Bool = true
    ) {
        self.id = id
        self.original = original
        self.alias = alias
        self.kind = kind
        self.createdAt = createdAt
        self.isEnabled = isEnabled
    }
}
