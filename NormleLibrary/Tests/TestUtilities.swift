//
//  TestUtilities.swift
//  Normle
//
//  Created by Hiromu Nakano on 2025/11/22.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

@testable import NormleLibrary
import SwiftData

var testContext: ModelContext {
    do {
        return .init(
            try .init(
                for: TransformRecord.self,
                MappingRule.self,
                Tag.self,
                configurations: .init(
                    isStoredInMemoryOnly: true
                )
            )
        )
    } catch {
        fatalError(error.localizedDescription)
    }
}
