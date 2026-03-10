//
//  SubscriptionSyncTip.swift
//  Normle
//
//  Created by Codex on 2026/03/10.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import SwiftUI
import TipKit

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
