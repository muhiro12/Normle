//
//  ICloudSyncTip.swift
//  Normle
//
//  Created by Codex on 2026/03/10.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import SwiftUI
import TipKit

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
