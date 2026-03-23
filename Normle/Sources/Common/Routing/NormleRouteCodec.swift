//
//  NormleRouteCodec.swift
//  Normle
//
//  Created by Codex on 2026/03/22.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import MHPlatform

nonisolated enum NormleRouteCodec {
    static let deepLink = MHDeepLinkCodec<NormleRoute>(
        configuration: .init(
            customScheme: "normle",
            preferredUniversalLinkHost: "normle.app",
            allowedUniversalLinkHosts: [
                "normle.app"
            ],
            universalLinkPathPrefix: "",
            preferredTransport: .customScheme
        )
    )
}
