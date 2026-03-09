//
//  NormleTips.swift
//  Normle
//
//  Created by Codex on 2026/03/10.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import SwiftUI
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

enum NormleTipManager {
    static func configure() {
        do {
            try Tips.configure([
                .displayFrequency(.immediate)
            ])
        } catch {
            assertionFailure(error.localizedDescription)
        }
    }

    static func donate(_ event: Tips.Event<Tips.EmptyDonation>) {
        Task {
            await event.donate()
        }
    }

    static func reset() throws {
        try Tips.resetDatastore()
    }
}

struct TransformPresetTip: Tip {
    var title: Text {
        Text("Choose presets first")
    }

    var message: Text? {
        Text("Start by selecting one or more transforms before you run and save a result.")
    }

    var image: Image? {
        Image(systemName: "slider.horizontal.3")
    }

    var rules: [Rule] {
        #Rule(NormleTipEvents.didOpenPresetSelector) { event in
            event.donations.count == 0
        }
    }

    var options: [any TipOption] {
        Tips.MaxDisplayCount(1)
    }
}

struct TransformSelectionMappingTip: Tip {
    var title: Text {
        Text("Select text to make a mapping")
    }

    var message: Text? {
        Text("Highlight part of your input to turn recurring replacements into a reusable mapping.")
    }

    var image: Image? {
        Image(systemName: "plus.rectangle.on.rectangle")
    }

    var rules: [Rule] {
        #Rule(NormleTipEvents.didStartMappingFromSelection) { event in
            event.donations.count == 0
        }
    }

    var options: [any TipOption] {
        Tips.MaxDisplayCount(1)
    }
}

struct MappingAddTip: Tip {
    var title: Text {
        Text("Create your first mapping")
    }

    var message: Text? {
        Text("Mappings let you replace repeated text patterns during transforms.")
    }

    var image: Image? {
        Image(systemName: "plus.circle")
    }

    var rules: [Rule] {
        #Rule(NormleTipEvents.didStartMappingCreation) { event in
            event.donations.count == 0
        }
    }

    var options: [any TipOption] {
        Tips.MaxDisplayCount(1)
    }
}

struct HistoryListTip: Tip {
    var title: Text {
        Text("Open a record for restore details")
    }

    var message: Text? {
        Text("History keeps source, target, and restore context for each saved transform.")
    }

    var image: Image? {
        Image(systemName: "clock.arrow.circlepath")
    }

    var rules: [Rule] {
        #Rule(NormleTipEvents.didOpenHistoryRecord) { event in
            event.donations.count == 0
        }
    }

    var options: [any TipOption] {
        Tips.MaxDisplayCount(1)
    }
}

struct HistoryRestoreTip: Tip {
    var title: Text {
        Text("Restore from this record")
    }

    var message: Text? {
        Text("Use this saved record to rebuild text when you need to recover a prior response.")
    }

    var image: Image? {
        Image(systemName: "arrow.uturn.backward.circle")
    }

    var rules: [Rule] {
        #Rule(NormleTipEvents.didOpenRestoreView) { event in
            event.donations.count == 0
        }
    }

    var options: [any TipOption] {
        Tips.MaxDisplayCount(1)
    }
}

struct SubscriptionSyncTip: Tip {
    var title: Text {
        Text("Subscription unlocks sync")
    }

    var message: Text? {
        Text("Open Subscription to enable iCloud sync across your devices.")
    }

    var image: Image? {
        Image(systemName: "icloud")
    }

    var options: [any TipOption] {
        Tips.MaxDisplayCount(1)
    }
}

struct ICloudSyncTip: Tip {
    var title: Text {
        Text("Turn on iCloud sync")
    }

    var message: Text? {
        Text("Enable this to keep history and mappings synced with iCloud.")
    }

    var image: Image? {
        Image(systemName: "icloud")
    }

    var options: [any TipOption] {
        Tips.MaxDisplayCount(1)
    }
}
