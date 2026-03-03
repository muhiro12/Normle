//
//  TransformRecordExtension.swift
//  Normle
//
//  Created by Hiromu Nakano on 2026/02/27.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import Foundation

public extension TransformRecord {
    /// Returns the mappings needed to restore the stored target text.
    var restoreMappings: [Mapping] {
        if mappings.isEmpty == false {
            return mappings
        }
        guard let sourceText = retainedSourceText,
              targetText.isEmpty == false else {
            return []
        }
        return [
            .init(
                original: sourceText,
                masked: targetText,
                kind: .other,
                occurrenceCount: 1
            )
        ]
    }
}
