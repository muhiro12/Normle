//
//  NormleTipManagerSmokeTests.swift
//  NormleTests
//
//  Created by Codex on 2026/03/23.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import Foundation
import NormleLibrary
import Testing

@testable import Normle

@MainActor
struct NormleTipManagerSmokeTests {
    @Test
    func resetTipsSchedulesTipResetForNextLaunch() {
        let suiteName = "NormleTipManagerSmokeTests.\(UUID().uuidString)"
        guard let userDefaults = UserDefaults(
            suiteName: suiteName
        ) else {
            Issue.record("Failed to create isolated user defaults")
            return
        }

        userDefaults.removePersistentDomain(
            forName: suiteName
        )
        defer {
            userDefaults.removePersistentDomain(
                forName: suiteName
            )
        }

        let screenModel = SettingsScreenModel()
        screenModel.resetTips(
            userDefaults: userDefaults
        )

        #expect(
            userDefaults.bool(forKey: tipResetStorageKey)
        )
        #expect(
            screenModel.alertTitle == String(localized: "Tips reset")
        )
        #expect(
            screenModel.alertMessage == String(
                localized: "Close and reopen Normle to show tips again."
            )
        )
        #expect(screenModel.isShowingAlert)
    }

    @Test
    func dismissAlertClearsTipResetMessage() {
        let suiteName = "NormleTipManagerSmokeTests.\(UUID().uuidString)"
        guard let userDefaults = UserDefaults(
            suiteName: suiteName
        ) else {
            Issue.record("Failed to create isolated user defaults")
            return
        }

        userDefaults.removePersistentDomain(
            forName: suiteName
        )
        defer {
            userDefaults.removePersistentDomain(
                forName: suiteName
            )
        }

        let screenModel = SettingsScreenModel()
        screenModel.resetTips(
            userDefaults: userDefaults
        )

        screenModel.dismissAlert()

        #expect(screenModel.isShowingAlert == false)
        #expect(screenModel.alertTitle.isEmpty)
        #expect(screenModel.alertMessage.isEmpty)
    }

    @Test
    func scheduledTipResetIsConsumedBeforeTipConfiguration() {
        let suiteName = "NormleTipManagerSmokeTests.\(UUID().uuidString)"
        guard let userDefaults = UserDefaults(
            suiteName: suiteName
        ) else {
            Issue.record("Failed to create isolated user defaults")
            return
        }

        userDefaults.removePersistentDomain(
            forName: suiteName
        )
        defer {
            userDefaults.removePersistentDomain(
                forName: suiteName
            )
        }

        var didResetDatastore = false
        NormleTipManager.scheduleReset(
            userDefaults: userDefaults
        )

        NormleTipManager.prepareForLaunch(
            userDefaults: userDefaults
        ) {
            didResetDatastore = true
        }

        #expect(didResetDatastore)
        #expect(
            userDefaults.object(forKey: tipResetStorageKey) == nil
        )
    }

    @Test
    func failedScheduledTipResetRemainsPendingForNextLaunch() {
        let suiteName = "NormleTipManagerSmokeTests.\(UUID().uuidString)"
        guard let userDefaults = UserDefaults(
            suiteName: suiteName
        ) else {
            Issue.record("Failed to create isolated user defaults")
            return
        }

        userDefaults.removePersistentDomain(
            forName: suiteName
        )
        defer {
            userDefaults.removePersistentDomain(
                forName: suiteName
            )
        }

        struct SampleError: Error {}

        var recordedError: (any Error)?
        NormleTipManager.scheduleReset(
            userDefaults: userDefaults
        )

        NormleTipManager.prepareForLaunch(
            userDefaults: userDefaults,
            resetDatastore: {
                throw SampleError()
            },
            handleError: { error in
                recordedError = error
            }
        )

        #expect(recordedError is SampleError)
        #expect(
            userDefaults.bool(forKey: tipResetStorageKey)
        )
    }

    @Test
    func tipConfigurationFailureStillConsumesScheduledReset() {
        let suiteName = "NormleTipManagerSmokeTests.\(UUID().uuidString)"
        guard let userDefaults = UserDefaults(
            suiteName: suiteName
        ) else {
            Issue.record("Failed to create isolated user defaults")
            return
        }

        userDefaults.removePersistentDomain(
            forName: suiteName
        )
        defer {
            userDefaults.removePersistentDomain(
                forName: suiteName
            )
        }

        struct SampleError: Error {}

        var didResetDatastore = false
        var didConfigureTips = false
        var recordedError: (any Error)?

        NormleTipManager.scheduleReset(
            userDefaults: userDefaults
        )
        NormleTipManager.configure(
            userDefaults: userDefaults,
            resetDatastore: {
                didResetDatastore = true
            },
            configureTips: { _ in
                didConfigureTips = true
                throw SampleError()
            },
            handleError: { error in
                recordedError = error
            }
        )

        #expect(didResetDatastore)
        #expect(didConfigureTips)
        #expect(recordedError is SampleError)
        #expect(
            userDefaults.object(forKey: tipResetStorageKey) == nil
        )
    }
}

private extension NormleTipManagerSmokeTests {
    var tipResetStorageKey: String {
        NormleUserDefaultsKeys.Standard.shouldResetTipsOnNextLaunch.rawValue
    }
}
