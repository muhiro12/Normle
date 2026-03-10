//
//  MaskingRule.swift
//  Normle
//
//  Created by Hiromu Nakano on 2025/11/23.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import Foundation
import SwiftData

public struct MaskingRule: Identifiable, Equatable, Sendable {
    public let id: String
    public var original: String
    public var masked: String
    public var kind: MappingKind
    public var date: Date
    public var isEnabled: Bool

    public init(
        original: String,
        masked: String,
        kind: MappingKind,
        date: Date = Date(),
        isEnabled: Bool = true,
        id: String = UUID().uuidString
    ) {
        self.id = id
        self.original = original
        self.masked = masked
        self.kind = kind
        self.date = date
        self.isEnabled = isEnabled
    }
}
