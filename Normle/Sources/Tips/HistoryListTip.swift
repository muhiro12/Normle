//
//  HistoryListTip.swift
//  Normle
//
//  Created by Codex on 2026/03/10.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import SwiftUI
import TipKit

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
