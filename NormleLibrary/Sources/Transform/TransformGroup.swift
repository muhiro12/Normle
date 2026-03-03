//
//  TransformGroup.swift
//  Normle
//
//  Created by Hiromu Nakano on 2026/03/03.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

/// Represents a selectable group of related transform presets.
public struct TransformGroup: Identifiable, Equatable, Sendable {
    public let id: String
    public let title: String
    public let options: [TransformPreset]
    public let isQRCodeGroup: Bool

    public init(
        title: String,
        options: [TransformPreset],
        isQRCodeGroup: Bool
    ) {
        self.id = title
        self.title = title
        self.options = options
        self.isQRCodeGroup = isQRCodeGroup
    }
}

public extension TransformGroup {
    /// Presets that change text casing.
    static let caseGroup: TransformGroup = .init(
        title: String(localized: "Case"),
        options: [
            .builtIn(.lowercase),
            .builtIn(.uppercase)
        ],
        isQRCodeGroup: false
    )

    /// Presets that convert alphanumeric width.
    static let alphanumericWidthGroup: TransformGroup = .init(
        title: String(localized: "Alphanumeric Width"),
        options: [
            .builtIn(.fullwidthAlphanumericToHalfwidth),
            .builtIn(.halfwidthAlphanumericToFullwidth)
        ],
        isQRCodeGroup: false
    )

    /// Presets that convert space width.
    static let spaceWidthGroup: TransformGroup = .init(
        title: String(localized: "Space Width"),
        options: [
            .builtIn(.fullwidthSpaceToHalfwidth),
            .builtIn(.halfwidthSpaceToFullwidth)
        ],
        isQRCodeGroup: false
    )

    /// Presets that convert katakana width.
    static let katakanaWidthGroup: TransformGroup = .init(
        title: String(localized: "Katakana Width"),
        options: [
            .builtIn(.halfwidthKatakanaToFullwidth),
            .builtIn(.fullwidthKatakanaToHalfwidth)
        ],
        isQRCodeGroup: false
    )

    /// Presets that convert digit width.
    static let digitsWidthGroup: TransformGroup = .init(
        title: String(localized: "Digits Width"),
        options: [
            .builtIn(.fullwidthDigitsToHalfwidth),
            .builtIn(.halfwidthDigitsToFullwidth)
        ],
        isQRCodeGroup: false
    )

    /// Presets that encode and decode Base64 text.
    static let base64Group: TransformGroup = .init(
        title: String(localized: "Base64"),
        options: [
            .builtIn(.base64Encode),
            .builtIn(.base64Decode)
        ],
        isQRCodeGroup: false
    )

    /// Presets that encode and decode URL text.
    static let urlGroup: TransformGroup = .init(
        title: String(localized: "URL"),
        options: [
            .builtIn(.urlEncode),
            .builtIn(.urlDecode)
        ],
        isQRCodeGroup: false
    )

    /// Presets that encode and decode QR content.
    static let qrGroup: TransformGroup = .init(
        title: String(localized: "QR"),
        options: [
            .builtIn(.qrEncode),
            .builtIn(.qrDecode)
        ],
        isQRCodeGroup: true
    )

    /// All transform groups shown in the preset picker.
    static let allGroups: [TransformGroup] = [
        caseGroup,
        alphanumericWidthGroup,
        spaceWidthGroup,
        katakanaWidthGroup,
        digitsWidthGroup,
        base64Group,
        urlGroup,
        qrGroup
    ]
}
