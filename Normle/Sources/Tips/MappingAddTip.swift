//
//  MappingAddTip.swift
//  Normle
//
//  Created by Codex on 2026/03/10.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import SwiftUI
import TipKit

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
