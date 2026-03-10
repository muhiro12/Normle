//
//  NormleTipEvents.swift
//  Normle
//
//  Created by Codex on 2026/03/10.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import TipKit

enum NormleTipEvents {
    nonisolated static let didOpenPresetSelector: Tips.Event<Tips.EmptyDonation> =
        .init(id: "did-open-preset-selector")
    nonisolated static let didStartMappingFromSelection: Tips.Event<Tips.EmptyDonation> =
        .init(id: "did-start-mapping-from-selection")
    nonisolated static let didStartMappingCreation: Tips.Event<Tips.EmptyDonation> =
        .init(id: "did-start-mapping-creation")
    nonisolated static let didOpenHistoryRecord: Tips.Event<Tips.EmptyDonation> =
        .init(id: "did-open-history-record")
    nonisolated static let didOpenRestoreView: Tips.Event<Tips.EmptyDonation> =
        .init(id: "did-open-restore-view")
}
