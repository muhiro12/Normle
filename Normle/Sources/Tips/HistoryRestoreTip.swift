//
//  HistoryRestoreTip.swift
//  Normle
//
//  Created by Codex on 2026/03/10.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import SwiftUI
import TipKit

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
