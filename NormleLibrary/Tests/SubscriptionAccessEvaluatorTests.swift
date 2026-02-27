@testable import NormleLibrary
import Testing

struct SubscriptionAccessEvaluatorTests {
    @Test func evaluateResolvesStateFromPurchasedProductIDs() {
        let state = SubscriptionAccessEvaluator.evaluate(
            purchasedProductIDs: Set(["com.example.subscription"]),
            productID: "com.example.subscription",
            isICloudOn: true
        )

        #expect(state.isSubscribeOn)
        #expect(state.isICloudOn)
    }

    @Test func evaluateKeepsICloudFlagWhenSubscriptionIsActive() {
        let state = SubscriptionAccessEvaluator.evaluate(
            hasActiveSubscription: true,
            isICloudOn: true
        )

        #expect(state.isSubscribeOn)
        #expect(state.isICloudOn)
    }

    @Test func evaluateDisablesICloudWhenSubscriptionIsInactive() {
        let state = SubscriptionAccessEvaluator.evaluate(
            hasActiveSubscription: false,
            isICloudOn: true
        )

        #expect(state.isSubscribeOn == false)
        #expect(state.isICloudOn == false)
    }

    @Test func evaluateAllowsPremiumWithoutSubscriptionWhenConfigured() {
        let state = SubscriptionAccessEvaluator.evaluate(
            hasActiveSubscription: false,
            isICloudOn: true,
            grantsPremiumAccessWithoutSubscription: true
        )

        #expect(state.isSubscribeOn)
        #expect(state.isICloudOn)
    }
}
