//
//  RestoreViewModel.swift
//
//
//  Created by Hiromu Nakano on 2025/11/23.
//

import MaskleLibrary
import Observation

@Observable
final class RestoreViewModel {
    var sourceText = String()
    var restoredText = String()

    func restore(
        with record: MaskRecord
    ) {
        _ = record
        restoredText = RestoreService.restore(
            text: sourceText,
            mappings: []
        )
    }
}
