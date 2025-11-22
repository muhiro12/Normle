//
//  MaskSessionStore.swift
//
//
//  Created by Hiromu Nakano on 2025/11/23.
//

import Foundation
import MaskleLibrary
import Observation

@Observable
final class MaskSessionStore {
    var manualRules: [MaskingRule]

    init(manualRules: [MaskingRule] = []) {
        self.manualRules = manualRules
    }
}

extension MaskSessionStore {
    var sortedRules: [MaskingRule] {
        manualRules.sorted {
            $0.createdAt > $1.createdAt
        }
    }

    func addRule(
        original: String = .init(),
        alias: String = .init(),
        kind: MappingKind = .custom
    ) -> UUID {
        manualRules.append(
            .init(
                original: original,
                alias: alias,
                kind: kind
            )
        )
        return manualRules.last?.id ?? .init()
    }

    func removeRule(id: UUID) {
        manualRules.removeAll {
            $0.id == id
        }
    }

    func updateRule(
        id: UUID,
        original: String,
        alias: String,
        kind: MappingKind
    ) {
        guard let index = manualRules.firstIndex(where: { $0.id == id }) else {
            return
        }
        manualRules[index].original = original
        manualRules[index].alias = alias
        manualRules[index].kind = kind
    }

    func rule(id: UUID) -> MaskingRule? {
        manualRules.first {
            $0.id == id
        }
    }
}
