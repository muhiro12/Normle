//
//  NormleAdMobConfiguration.swift
//  Normle
//
//  Created by Codex on 2026/03/11.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

enum NormleAdMobConfiguration {
    // Matches the shared debug native ad unit used in sibling apps.
    static let nativeAdUnitIDDev = "ca-app-pub-3940256099942544/3986624511"

    static var nativeAdUnitID: String? {
        #if DEBUG
        nativeAdUnitIDDev
        #else
        nil
        #endif
    }
}
