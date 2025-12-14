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
    case base64Encode
    case base64Decode
    case urlEncode
    case urlDecode

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
        case .base64Encode:
            "Base64 Encode"
        case .base64Decode:
            "Base64 Decode"
        case .urlEncode:
            "URL Encode"
        case .urlDecode:
            "URL Decode"
        }
    }

    public func apply(to text: String) -> Result<String, BaseTransformError> {
        switch self {
        case .fullwidthAlphanumericToHalfwidth:
            return .success(applyingTransform(text, transform: .fullwidthToHalfwidth))
        case .halfwidthAlphanumericToFullwidth:
            return .success(applyingTransform(text, transform: .fullwidthToHalfwidth, reverse: true))
        case .fullwidthSpaceToHalfwidth:
            return .success(text.replacingOccurrences(of: "　", with: " "))
        case .halfwidthSpaceToFullwidth:
            return .success(text.replacingOccurrences(of: " ", with: "　"))
        case .halfwidthKatakanaToFullwidth:
            return .success(applyingTransform(text, transform: .fullwidthToHalfwidth, reverse: true))
        case .fullwidthKatakanaToHalfwidth:
            return .success(applyingTransform(text, transform: .fullwidthToHalfwidth))
        case .lowercase:
            return .success(text.lowercased())
        case .uppercase:
            return .success(text.uppercased())
        case .fullwidthDigitsToHalfwidth:
            return .success(convertDigits(text, toFullwidth: false))
        case .halfwidthDigitsToFullwidth:
            return .success(convertDigits(text, toFullwidth: true))
        case .base64Encode:
            let data = Data(text.utf8)
            return .success(data.base64EncodedString())
        case .base64Decode:
            guard let data = Data(base64Encoded: text) else {
                return .failure(.invalidBase64)
            }
            guard let decoded = String(data: data, encoding: .utf8) else {
                return .failure(.invalidBase64)
            }
            return .success(decoded)
        case .urlEncode:
            var allowedCharacters = CharacterSet.urlQueryAllowed
            allowedCharacters.remove(charactersIn: "+?")
            guard let encoded = text.addingPercentEncoding(withAllowedCharacters: allowedCharacters) else {
                return .failure(.invalidURL)
            }
            return .success(encoded)
        case .urlDecode:
            guard let decoded = text.removingPercentEncoding else {
                return .failure(.invalidURL)
            }
            return .success(decoded)
        }
    }
}

public enum BaseTransformError: LocalizedError, Equatable {
    case invalidBase64
    case invalidURL

    public var errorDescription: String? {
        switch self {
        case .invalidBase64:
            "Failed to decode Base64 text."
        case .invalidURL:
            "Failed to process URL text."
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
