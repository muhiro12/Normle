//
//  MaskingPreferences.swift
//  Normle
//
//  Created by Hiromu Nakano on 2026/03/03.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

/// Stores the persisted automatic masking preferences.
public struct MaskingPreferences: Codable, Equatable, Sendable {
    public var isURLMaskingEnabled: Bool
    public var isEmailMaskingEnabled: Bool
    public var isPhoneMaskingEnabled: Bool

    public init(
        isURLMaskingEnabled: Bool,
        isEmailMaskingEnabled: Bool,
        isPhoneMaskingEnabled: Bool
    ) {
        self.isURLMaskingEnabled = isURLMaskingEnabled
        self.isEmailMaskingEnabled = isEmailMaskingEnabled
        self.isPhoneMaskingEnabled = isPhoneMaskingEnabled
    }
}

public extension MaskingPreferences {
    /// The default masking preferences for new users.
    static var defaults: MaskingPreferences {
        .init(
            isURLMaskingEnabled: true,
            isEmailMaskingEnabled: true,
            isPhoneMaskingEnabled: true
        )
    }

    /// Converts the persisted preferences into runtime masking options.
    var maskingOptions: MaskingOptions {
        .init(
            isURLMaskingEnabled: isURLMaskingEnabled,
            isEmailMaskingEnabled: isEmailMaskingEnabled,
            isPhoneMaskingEnabled: isPhoneMaskingEnabled
        )
    }
}
