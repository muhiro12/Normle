//
//  NormlePendingRouteStore.swift
//  Normle
//
//  Created by Codex on 2026/03/21.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import Foundation
import MHPlatform

struct NormlePendingRouteStore {
    private enum Constants {
        static let storageKey = "normle.pendingDeepLink"
    }

    let source: MHDeepLinkStore

    init(
        userDefaults: UserDefaults = .standard
    ) {
        source = .init(
            userDefaults: userDefaults,
            key: Constants.storageKey
        )
    }

    func store(
        _ url: URL
    ) {
        source.ingest(url)
    }

    @discardableResult
    func store(
        _ route: NormleRoute
    ) -> URL? {
        source.ingest(
            route,
            using: NormleRouteCodec.deepLink
        )
    }

    func clear() {
        source.clear()
    }

    func consumeLatestURL() -> URL? {
        source.consumeLatest()
    }

    func consumeLatestRoute() -> NormleRoute? {
        source.consumeLatest(
            using: NormleRouteCodec.deepLink
        )
    }
}
