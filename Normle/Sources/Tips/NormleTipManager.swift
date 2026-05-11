//
//  NormleTipManager.swift
//  Normle
//
//  Created by Codex on 2026/03/10.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import Foundation
import NormleLibrary
import TipKit

enum NormleTipManager {
    static func configure(
        userDefaults: UserDefaults = .standard,
        resetDatastore: () throws -> Void = Tips.resetDatastore,
        configureTips: ([Tips.ConfigurationOption]) throws -> Void = Tips.configure,
        handleError: (any Error) -> Void = { error in
            assertionFailure(error.localizedDescription)
        }
    ) {
        prepareForLaunch(
            userDefaults: userDefaults,
            resetDatastore: resetDatastore,
            handleError: handleError
        )

        do {
            try configureTips([
                .displayFrequency(.immediate)
            ])
        } catch {
            handleError(error)
        }
    }

    static func donate(_ event: Tips.Event<Tips.EmptyDonation>) {
        Task {
            await event.donate()
        }
    }

    static func scheduleReset(
        userDefaults: UserDefaults = .standard
    ) {
        userDefaults.set(
            true,
            forKey: NormleUserDefaultsKeys.Standard.shouldResetTipsOnNextLaunch.rawValue
        )
    }

    static func prepareForLaunch(
        userDefaults: UserDefaults = .standard,
        resetDatastore: () throws -> Void = Tips.resetDatastore,
        handleError: (any Error) -> Void = { error in
            assertionFailure(error.localizedDescription)
        }
    ) {
        let storageKey = NormleUserDefaultsKeys.Standard.shouldResetTipsOnNextLaunch.rawValue
        guard userDefaults.bool(forKey: storageKey) else {
            return
        }

        do {
            try resetDatastore()
            userDefaults.removeObject(
                forKey: storageKey
            )
        } catch {
            handleError(error)
        }
    }
}
