//
//  TransformRecord+Restore.swift
//
//
//  Created by Hiromu Nakano on 2026/02/27.
//

import Foundation

public extension TransformRecord {
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
