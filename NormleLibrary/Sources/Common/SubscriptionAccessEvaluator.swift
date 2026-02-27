//
//  SubscriptionAccessEvaluator.swift
//
//
//  Created by Hiromu Nakano on 2025/11/23.
//

public struct SubscriptionAccessState {
    public let isSubscribeOn: Bool
    public let isICloudOn: Bool

    public init(
        isSubscribeOn: Bool,
        isICloudOn: Bool
    ) {
        self.isSubscribeOn = isSubscribeOn
        self.isICloudOn = isICloudOn
    }
}

public enum SubscriptionAccessEvaluator {
    public static func evaluate(
        purchasedProductIDs: Set<String>,
        productID: String,
        isICloudOn: Bool
    ) -> SubscriptionAccessState {
        evaluate(
            hasActiveSubscription: purchasedProductIDs.contains(productID),
            isICloudOn: isICloudOn
        )
    }

    public static func evaluate(
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
