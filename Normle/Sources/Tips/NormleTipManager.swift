//
//  NormleTipManager.swift
//  Normle
//
//  Created by Codex on 2026/03/10.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import TipKit

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
