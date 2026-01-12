//
//  SubscriptionAccessEvaluator.swift
//
//
//  Created by Hiromu Nakano on 2025/11/23.
//

struct SubscriptionAccessEvaluator {
    static func evaluate(
        hasActiveSubscription: Bool,
        isICloudOn: Bool
    ) -> SubscriptionAccessState {
        if hasActiveSubscription {
            return .init(
                isSubscribeOn: true,
                isICloudOn: isICloudOn
            )
        }
        return .init(
            isSubscribeOn: false,
            isICloudOn: false
        )
    }
}

struct SubscriptionAccessState {
    let isSubscribeOn: Bool
    let isICloudOn: Bool
}
