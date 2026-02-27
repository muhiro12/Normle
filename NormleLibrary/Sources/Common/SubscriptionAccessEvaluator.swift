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
        isICloudOn: Bool,
        grantsPremiumAccessWithoutSubscription: Bool = false
    ) -> SubscriptionAccessState {
        evaluate(
            hasActiveSubscription: purchasedProductIDs.contains(productID),
            isICloudOn: isICloudOn,
            grantsPremiumAccessWithoutSubscription: grantsPremiumAccessWithoutSubscription
        )
    }

    public static func evaluate(
        hasActiveSubscription: Bool,
        isICloudOn: Bool,
        grantsPremiumAccessWithoutSubscription: Bool = false
    ) -> SubscriptionAccessState {
        if hasActiveSubscription || grantsPremiumAccessWithoutSubscription {
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
