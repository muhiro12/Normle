//
//  RestoreViewModel.swift
//  Normle
//
//  Created by Hiromu Nakano on 2025/11/23.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import NormleLibrary
import Observation

@Observable
final class RestoreViewModel {
    var sourceText = String()
    var restoredText = String()

    func restore(
        with record: TransformRecord
    ) {
        restoredText = RestoreService.restore(
            text: sourceText,
            mappings: record.restoreMappings
        )
    }
}
