//
//  TransformSelectionMappingTip.swift
//  Normle
//
//  Created by Codex on 2026/03/10.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import SwiftUI
import TipKit

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
