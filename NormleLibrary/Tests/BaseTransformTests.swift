import CoreGraphics
import ImageIO
@testable import NormleLibrary
import Testing
import UniformTypeIdentifiers

struct BaseTransformTests {
    @Test func fullwidthAlphanumericToHalfwidth() throws {
        let input = "ＡＢＣ１２３"
        let result = try BaseTransform.fullwidthAlphanumericToHalfwidth.apply(text: input).get()
        #expect(result == "ABC123")
    }

    @Test func halfwidthAlphanumericToFullwidth() throws {
        let input = "ABC123"
        let result = try BaseTransform.halfwidthAlphanumericToFullwidth.apply(text: input).get()
        #expect(result == "ＡＢＣ１２３")
    }

    @Test func lowercaseAndUppercase() throws {
        #expect(try BaseTransform.lowercase.apply(text: "AbC").get() == "abc")
        #expect(try BaseTransform.uppercase.apply(text: "AbC").get() == "ABC")
    }

    @Test func digitConversion() throws {
        #expect(try BaseTransform.fullwidthDigitsToHalfwidth.apply(text: "１２３").get() == "123")
        #expect(try BaseTransform.halfwidthDigitsToFullwidth.apply(text: "123").get() == "１２３")
    }

    @Test func spaceConversion() throws {
        #expect(try BaseTransform.fullwidthSpaceToHalfwidth.apply(text: "a　b").get() == "a b")
        #expect(try BaseTransform.halfwidthSpaceToFullwidth.apply(text: "a b").get() == "a　b")
    }

    @Test func katakanaConversion() throws {
        let input = "ｶﾀｶﾅ"
        let result = try BaseTransform.halfwidthKatakanaToFullwidth.apply(text: input).get()
        #expect(result == "カタカナ")
    }

    @Test func base64Encode() throws {
        let result = try BaseTransform.base64Encode.apply(text: "Normle Masking").get()
        #expect(result == "Tm9ybWxlIE1hc2tpbmc=")
    }

    @Test func base64Decode() throws {
        let result = try BaseTransform.base64Decode.apply(text: "Tm9ybWxlIE1hc2tpbmc=").get()
        #expect(result == "Normle Masking")

        let failure = BaseTransform.base64Decode.apply(text: "%%%")
        switch failure {
        case .success:
            Issue.record("Expected Base64 decode to fail")
        case .failure(let error):
            #expect(error == .invalidBase64)
        }
    }

    @Test func urlEncode() throws {
        let text = "mask me+ please?"
        let result = try BaseTransform.urlEncode.apply(text: text).get()
        #expect(result == "mask%20me%2B%20please%3F")
    }

    @Test func urlDecode() throws {
        let result = try BaseTransform.urlDecode.apply(text: "mask%20me%2B%20please%3F").get()
        #expect(result == "mask me+ please?")

        let failure = BaseTransform.urlDecode.apply(text: "%ZZ")
        switch failure {
        case .success:
            Issue.record("Expected URL decode to fail")
        case .failure(let error):
            #expect(error == .invalidURL)
        }
    }

    @Test func qrEncodeAndDecode() throws {
        let text = "Normle QR"
        let imageResult = BaseTransform.qrEncode.qrCodeImage(for: text)
        switch imageResult {
        case .success(let image):
            guard let imageData = pngData(from: image) else {
                Issue.record("Failed to build PNG data for QR")
                return
            }
            let decoded = try BaseTransform.qrDecode.apply(
                text: String(),
                imageData: imageData
            ).get()
            #expect(decoded == text)
        case .failure(let error):
            Issue.record("Failed to generate QR: \(error)")
        }
    }

    @Test func qrDecodeFailsWithNonImageData() {
        guard let imageData = makeSolidPNGData() else {
            Issue.record("Failed to build PNG data for non-QR test")
            return
        }
        let result = BaseTransform.qrDecode.apply(
            text: String(),
            imageData: imageData
        )
        switch result {
        case .success:
            Issue.record("Expected QR decode to fail for non-image data")
        case .failure(let error):
            #expect(error == .qrNotDetected)
        }
    }

    @Test func qrEncodeApplyReturnsEmptyText() throws {
        let result = try BaseTransform.qrEncode.apply(text: String()).get()
        #expect(result.isEmpty)
    }
}

private extension BaseTransformTests {
    func pngData(from image: CGImage) -> Data? {
        let mutableData = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(
            mutableData,
            UTType.png.identifier as CFString,
            1,
            nil
        ) else {
            return nil
        }

        CGImageDestinationAddImage(destination, image, nil)
        guard CGImageDestinationFinalize(destination) else {
            return nil
        }

        return mutableData as Data
    }

    func makeSolidPNGData() -> Data? {
        let width = 4
        let height = 4
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ) else {
            return nil
        }

        context.setFillColor(
            CGColor(
                red: 1,
                green: 1,
                blue: 1,
                alpha: 1
            )
        )
        context.fill(
            CGRect(
                x: 0,
                y: 0,
                width: CGFloat(width),
                height: CGFloat(height)
            )
        )

        guard let image = context.makeImage() else {
            return nil
        }

        return pngData(from: image)
    }
}
