import CoreGraphics
import CoreImage
@testable import NormleLibrary
import Testing

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
            let context = CIContext()
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let ciImage = CIImage(cgImage: image)
            guard
                let data = context.pngRepresentation(
                    of: ciImage,
                    format: CIFormat.RGBA8,
                    colorSpace: colorSpace
                )
            else {
                Issue.record("Failed to build PNG data for QR")
                return
            }
            let decoded = try BaseTransform.qrDecode.apply(text: String(), imageData: data).get()
            #expect(decoded == text)
        case .failure(let error):
            Issue.record("Failed to generate QR: \(error)")
        }
    }
}
