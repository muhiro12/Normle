//
//  BaseTransform.swift
//  Normle
//
//  Created by Hiromu Nakano on 2025/11/23.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import CoreImage.CIFilterBuiltins
import Foundation

public enum BaseTransform: CaseIterable, Identifiable, Sendable {
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
    case qrEncode
    case qrDecode

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
        case .qrEncode:
            "QR Encode"
        case .qrDecode:
            "QR Decode"
        }
    }

    public func apply(text: String, imageData: Data? = nil) -> Result<String, BaseTransformError> {
        if let transformedText = transformedText(for: text) {
            return .success(transformedText)
        }

        if let base64Result = base64Result(for: text) {
            return base64Result
        }

        if let urlResult = urlResult(for: text) {
            return urlResult
        }

        if let qrResult = qrResult(imageData: imageData) {
            return qrResult
        }

        assertionFailure("Unhandled transform: \(self)")
        return .success(text)
    }
}

private extension BaseTransform {
    enum ScalarRange {
        static let halfwidthDigitsStart = scalarValue(for: "0")
        static let halfwidthDigitsEnd = scalarValue(for: "9")
        static let fullwidthDigitsStart = scalarValue(for: "０")
        static let fullwidthDigitsEnd = scalarValue(for: "９")
        static let fullwidthOffset = fullwidthDigitsStart - halfwidthDigitsStart

        private static func scalarValue(for character: Character) -> UInt32 {
            guard let scalar = String(character).unicodeScalars.first else {
                fatalError("Expected a single unicode scalar.")
            }
            return scalar.value
        }
    }

    enum QRCode {
        static let scale = 10.0
    }

    func transformedText(for text: String) -> String? {
        if let transformedText = transformedWidthText(for: text) {
            return transformedText
        }
        if let transformedText = transformedCaseText(for: text) {
            return transformedText
        }
        return transformedDigitText(for: text)
    }

    func transformedWidthText(for text: String) -> String? {
        switch self {
        case .fullwidthAlphanumericToHalfwidth:
            return applyingTransform(
                text,
                transform: .fullwidthToHalfwidth
            )
        case .halfwidthAlphanumericToFullwidth:
            return applyingTransform(
                text,
                transform: .fullwidthToHalfwidth,
                reverse: true
            )
        case .fullwidthSpaceToHalfwidth:
            return text.replacingOccurrences(
                of: "　",
                with: " "
            )
        case .halfwidthSpaceToFullwidth:
            return text.replacingOccurrences(
                of: " ",
                with: "　"
            )
        case .halfwidthKatakanaToFullwidth:
            return applyingTransform(
                text,
                transform: .fullwidthToHalfwidth,
                reverse: true
            )
        case .fullwidthKatakanaToHalfwidth:
            return applyingTransform(
                text,
                transform: .fullwidthToHalfwidth
            )
        default:
            return nil
        }
    }

    func transformedCaseText(for text: String) -> String? {
        switch self {
        case .lowercase:
            return text.lowercased()
        case .uppercase:
            return text.uppercased()
        default:
            return nil
        }
    }

    func transformedDigitText(for text: String) -> String? {
        switch self {
        case .fullwidthDigitsToHalfwidth:
            return convertDigits(
                text,
                toFullwidth: false
            )
        case .halfwidthDigitsToFullwidth:
            return convertDigits(
                text,
                toFullwidth: true
            )
        default:
            return nil
        }
    }

    func base64Result(for text: String) -> Result<String, BaseTransformError>? {
        switch self {
        case .base64Encode:
            let data = Data(text.utf8)
            return .success(data.base64EncodedString())
        case .base64Decode:
            guard let data = Data(base64Encoded: text),
                  let decoded = String(data: data, encoding: .utf8) else {
                return .failure(.invalidBase64)
            }
            return .success(decoded)
        default:
            return nil
        }
    }

    func urlResult(for text: String) -> Result<String, BaseTransformError>? {
        switch self {
        case .urlEncode:
            var allowedCharacters = CharacterSet.urlQueryAllowed
            allowedCharacters.remove(charactersIn: "+?")
            guard let encoded = text.addingPercentEncoding(
                withAllowedCharacters: allowedCharacters
            ) else {
                return .failure(.invalidURL)
            }
            return .success(encoded)
        case .urlDecode:
            guard let decoded = text.removingPercentEncoding else {
                return .failure(.invalidURL)
            }
            return .success(decoded)
        default:
            return nil
        }
    }

    func qrResult(imageData: Data?) -> Result<String, BaseTransformError>? {
        switch self {
        case .qrEncode:
            // targetText is intentionally empty for QR encode; QR image is generated at call site.
            return .success(String())
        case .qrDecode:
            guard let imageData,
                  let decoded = decodeQRCode(from: imageData) else {
                return .failure(.qrNotDetected)
            }
            return .success(decoded)
        default:
            return nil
        }
    }

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
               scalar.value >= ScalarRange.halfwidthDigitsStart,
               scalar.value <= ScalarRange.halfwidthDigitsEnd,
               let converted = UnicodeScalar(
                scalar.value + ScalarRange.fullwidthOffset
               ) {
                return converted
            }
            if toFullwidth == false,
               scalar.value >= ScalarRange.fullwidthDigitsStart,
               scalar.value <= ScalarRange.fullwidthDigitsEnd,
               let converted = UnicodeScalar(
                scalar.value - ScalarRange.fullwidthOffset
               ) {
                return converted
            }
            return scalar
        }
        return String(String.UnicodeScalarView(scalars))
    }

    func makeQRCodeImage(for text: String) -> CGImage? {
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(text.utf8)
        filter.correctionLevel = "H"

        guard let outputImage = filter.outputImage else {
            return nil
        }
        let scaledImage = outputImage.transformed(
            by: CGAffineTransform(
                scaleX: QRCode.scale,
                y: QRCode.scale
            )
        )

        let context = makeCIContext()
        let colorSpace = CGColorSpaceCreateDeviceGray()
        return context.createCGImage(scaledImage, from: scaledImage.extent, format: .L8, colorSpace: colorSpace)
    }

    func decodeQRCode(from imageData: Data) -> String? {
        guard let ciImage = CIImage(data: imageData) else {
            return nil
        }
        let context = makeCIContext()
        guard let detector = CIDetector(
            ofType: CIDetectorTypeQRCode,
            context: context,
            options: [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        ) else {
            return nil
        }
        let features = detector.features(in: ciImage)
        let messages = features.compactMap { ($0 as? CIQRCodeFeature)?.messageString }
        return messages.first
    }

    func makeCIContext() -> CIContext {
        #if targetEnvironment(simulator)
        return CIContext(options: [
            CIContextOption.useSoftwareRenderer: true
        ])
        #else
        return CIContext()
        #endif
    }
}

public extension BaseTransform {
    /// Generates a QR code image for the provided text when supported by the transform.
    func qrCodeImage(for text: String) -> Result<CGImage, BaseTransformError> {
        guard let image = makeQRCodeImage(for: text) else {
            return .failure(.qrGenerationFailed)
        }
        return .success(image)
    }
}
