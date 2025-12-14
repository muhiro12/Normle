//
//  BaseTransform.swift
//
//
//  Created by Hiromu Nakano on 2025/11/23.
//

import Foundation

public enum BaseTransform: CaseIterable, Identifiable {
    case fullwidthAlphanumericToHalfwidth
    case halfwidthAlphanumericToFullwidth
    case fullwidthSpaceToHalfwidth
    case halfwidthSpaceToFullwidth
    case halfwidthKatakanaToFullwidth
    case fullwidthKatakanaToHalfwidth
    case lowercase
    case uppercase
    case fullwidthDigitsToHalfwidth
    case halfwidthDigitsToFullwidth

    public var id: Self { self }

    public var title: String {
        switch self {
        case .fullwidthAlphanumericToHalfwidth:
            "Fullwidth alphanumeric → Halfwidth"
        case .halfwidthAlphanumericToFullwidth:
            "Halfwidth alphanumeric → Fullwidth"
        case .fullwidthSpaceToHalfwidth:
            "Fullwidth space → Halfwidth"
        case .halfwidthSpaceToFullwidth:
            "Halfwidth space → Fullwidth"
        case .halfwidthKatakanaToFullwidth:
            "Halfwidth katakana → Fullwidth"
        case .fullwidthKatakanaToHalfwidth:
            "Fullwidth katakana → Halfwidth"
        case .lowercase:
            "Lowercase"
        case .uppercase:
            "Uppercase"
        case .fullwidthDigitsToHalfwidth:
            "Fullwidth digits → Halfwidth"
        case .halfwidthDigitsToFullwidth:
            "Halfwidth digits → Fullwidth"
        }
    }

    public func apply(to text: String) -> String {
        switch self {
        case .fullwidthAlphanumericToHalfwidth:
            return applyingTransform(text, transform: .fullwidthToHalfwidth)
        case .halfwidthAlphanumericToFullwidth:
            return applyingTransform(text, transform: .fullwidthToHalfwidth, reverse: true)
        case .fullwidthSpaceToHalfwidth:
            return text.replacingOccurrences(of: "　", with: " ")
        case .halfwidthSpaceToFullwidth:
            return text.replacingOccurrences(of: " ", with: "　")
        case .halfwidthKatakanaToFullwidth:
            return applyingTransform(text, transform: .fullwidthToHalfwidth, reverse: true)
        case .fullwidthKatakanaToHalfwidth:
            return applyingTransform(text, transform: .fullwidthToHalfwidth)
        case .lowercase:
            return text.lowercased()
        case .uppercase:
            return text.uppercased()
        case .fullwidthDigitsToHalfwidth:
            return convertDigits(text, toFullwidth: false)
        case .halfwidthDigitsToFullwidth:
            return convertDigits(text, toFullwidth: true)
        }
    }
}

private extension BaseTransform {
    func applyingTransform(
        _ text: String,
        transform: StringTransform,
        reverse: Bool = false
    ) -> String {
        text.applyingTransform(transform, reverse: reverse) ?? text
    }

    func convertDigits(
        _ text: String,
        toFullwidth: Bool
    ) -> String {
        let scalars: [UnicodeScalar] = text.unicodeScalars.map { scalar in
            if toFullwidth,
               scalar.value >= 0x30,
               scalar.value <= 0x39,
               let converted = UnicodeScalar(scalar.value + 0xFEE0) {
                return converted
            }
            if toFullwidth == false,
               scalar.value >= 0xFF10,
               scalar.value <= 0xFF19,
               let converted = UnicodeScalar(scalar.value - 0xFEE0) {
                return converted
            }
            return scalar
        }
        return String(String.UnicodeScalarView(scalars))
    }
}
