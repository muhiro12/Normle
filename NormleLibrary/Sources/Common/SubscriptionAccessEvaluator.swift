//
//  SubscriptionAccessEvaluator.swift
//  Normle
//
//  Created by Hiromu Nakano on 2025/11/23.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

/// Resolves premium access and iCloud availability from subscription state.
public enum SubscriptionAccessEvaluator {
    /// Evaluates access using the set of purchased product identifiers.
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

    /// Evaluates access using a precomputed subscription flag.
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
