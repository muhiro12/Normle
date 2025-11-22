//
//  SettingsStore.swift
//
//
//  Created by Hiromu Nakano on 2025/11/23.
//

import Foundation
import Observation

@Observable
final class SettingsStore {
    private enum Key {
        static let isURLMaskingEnabled = "Maskle.settings.isURLMaskingEnabled"
        static let isEmailMaskingEnabled = "Maskle.settings.isEmailMaskingEnabled"
        static let isPhoneMaskingEnabled = "Maskle.settings.isPhoneMaskingEnabled"
        static let isHistoryAutoSaveEnabled = "Maskle.settings.isHistoryAutoSaveEnabled"
    }

    @ObservationIgnored
    private let defaults: UserDefaults

    var isURLMaskingEnabled: Bool {
        didSet {
            save()
        }
    }

    var isEmailMaskingEnabled: Bool {
        didSet {
            save()
        }
    }

    var isPhoneMaskingEnabled: Bool {
        didSet {
            save()
        }
    }

    var isHistoryAutoSaveEnabled: Bool {
        didSet {
            save()
        }
    }

    init(
        defaults: UserDefaults = .standard
    ) {
        self.defaults = defaults

        isURLMaskingEnabled = defaults.object(forKey: Key.isURLMaskingEnabled) as? Bool ?? true
        isEmailMaskingEnabled = defaults.object(forKey: Key.isEmailMaskingEnabled) as? Bool ?? true
        isPhoneMaskingEnabled = defaults.object(forKey: Key.isPhoneMaskingEnabled) as? Bool ?? true
        isHistoryAutoSaveEnabled = defaults.object(forKey: Key.isHistoryAutoSaveEnabled) as? Bool ?? true
    }
}

private extension SettingsStore {
    func save() {
        defaults.set(isURLMaskingEnabled, forKey: Key.isURLMaskingEnabled)
        defaults.set(isEmailMaskingEnabled, forKey: Key.isEmailMaskingEnabled)
        defaults.set(isPhoneMaskingEnabled, forKey: Key.isPhoneMaskingEnabled)
        defaults.set(isHistoryAutoSaveEnabled, forKey: Key.isHistoryAutoSaveEnabled)
    }
}
