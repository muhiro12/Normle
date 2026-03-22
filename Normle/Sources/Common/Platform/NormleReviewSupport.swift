//
//  NormleReviewSupport.swift
//  Normle
//
//  Created by Codex on 2026/03/10.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import MHLogging
import MHReviewPolicy

enum NormleReviewSupport {
    enum Context {
        case appActivation
        case mutation
    }

    private enum Constants {
        static let appActivationLotteryMaxExclusive = 10
        static let mutationLotteryMaxExclusive = 5
        static let requestDelaySeconds = 2
    }

    static func logger(
        source: String = #fileID
    ) -> MHLogger {
        NormleApp.logger(
            category: "ReviewFlow",
            source: source
        )
    }

    static func policy(
        for context: Context
    ) -> MHReviewPolicy {
        let lotteryMaxExclusive: Int

        switch context {
        case .appActivation:
            lotteryMaxExclusive = Constants.appActivationLotteryMaxExclusive
        case .mutation:
            lotteryMaxExclusive = Constants.mutationLotteryMaxExclusive
        }

        return .init(
            lotteryMaxExclusive: lotteryMaxExclusive,
            requestDelay: .seconds(Constants.requestDelaySeconds)
        )
    }

    static func flow(
        context: Context,
        source: String = #fileID
    ) -> MHReviewFlow {
        .init(
            policy: policy(for: context),
            logger: logger(source: source)
        )
    }
}
