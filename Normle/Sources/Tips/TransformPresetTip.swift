//
//  TransformPresetTip.swift
//  Normle
//
//  Created by Codex on 2026/03/10.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import SwiftUI
import TipKit

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
