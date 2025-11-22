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
        with session: MaskingSession
    ) {
        let mappings: [Mapping] = session.mappings?.compactMap { record in
            guard let kind = record.kind else {
                return nil
            }
            return Mapping(
                original: record.original,
                alias: record.alias,
                kind: kind,
                occurrenceCount: record.occurrenceCount
            )
        } ?? []

        restoredText = RestoreService.restore(
            text: sourceText,
            mappings: mappings
        )
    }
}
