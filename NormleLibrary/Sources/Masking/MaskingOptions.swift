//
//  MaskingOptions.swift
//  Normle
//
//  Created by Hiromu Nakano on 2025/11/23.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import Foundation

public struct MaskingOptions: Equatable {
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
