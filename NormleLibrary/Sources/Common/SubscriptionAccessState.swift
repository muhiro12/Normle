//
//  SubscriptionAccessState.swift
//  Normle
//
//  Created by Hiromu Nakano on 2026/03/03.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

/// Describes the premium and iCloud access currently available to the user.
public struct SubscriptionAccessState {
    /// Indicates whether premium access is available.
    public let isSubscribeOn: Bool
    /// Indicates whether iCloud sync should remain enabled.
    public let isICloudOn: Bool

    /// Creates a subscription access state.
    public init(
        isSubscribeOn: Bool,
        isICloudOn: Bool
    ) {
        self.isSubscribeOn = isSubscribeOn
        self.isICloudOn = isICloudOn
    }
}
