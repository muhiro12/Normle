@testable import NormleLibrary
import Testing

struct BaseTransformTests {
    @Test func fullwidthAlphanumericToHalfwidth() throws {
        let input = "ＡＢＣ１２３"
        let result = try BaseTransform.fullwidthAlphanumericToHalfwidth.apply(to: input).get()
        #expect(result == "ABC123")
    }

    @Test func halfwidthAlphanumericToFullwidth() throws {
        let input = "ABC123"
        let result = try BaseTransform.halfwidthAlphanumericToFullwidth.apply(to: input).get()
        #expect(result == "ＡＢＣ１２３")
    }

    @Test func lowercaseAndUppercase() throws {
        #expect(try BaseTransform.lowercase.apply(to: "AbC").get() == "abc")
        #expect(try BaseTransform.uppercase.apply(to: "AbC").get() == "ABC")
    }

    @Test func digitConversion() throws {
        #expect(try BaseTransform.fullwidthDigitsToHalfwidth.apply(to: "１２３").get() == "123")
        #expect(try BaseTransform.halfwidthDigitsToFullwidth.apply(to: "123").get() == "１２３")
    }

    @Test func spaceConversion() throws {
        #expect(try BaseTransform.fullwidthSpaceToHalfwidth.apply(to: "a　b").get() == "a b")
        #expect(try BaseTransform.halfwidthSpaceToFullwidth.apply(to: "a b").get() == "a　b")
    }

    @Test func katakanaConversion() throws {
        let input = "ｶﾀｶﾅ"
        let result = try BaseTransform.halfwidthKatakanaToFullwidth.apply(to: input).get()
        #expect(result == "カタカナ")
    }

    @Test func base64Encode() throws {
        let result = try BaseTransform.base64Encode.apply(to: "Normle Masking").get()
        #expect(result == "Tm9ybWxlIE1hc2tpbmc=")
    }

    @Test func base64Decode() throws {
        let result = try BaseTransform.base64Decode.apply(to: "Tm9ybWxlIE1hc2tpbmc=").get()
        #expect(result == "Normle Masking")

        let failure = BaseTransform.base64Decode.apply(to: "%%%")
        switch failure {
        case .success:
            Issue.record("Expected Base64 decode to fail")
        case .failure(let error):
            #expect(error == .invalidBase64)
        }
    }

    @Test func urlEncode() throws {
        let text = "mask me+ please?"
        let result = try BaseTransform.urlEncode.apply(to: text).get()
        #expect(result == "mask%20me%2B%20please%3F")
    }

    @Test func urlDecode() throws {
        let result = try BaseTransform.urlDecode.apply(to: "mask%20me%2B%20please%3F").get()
        #expect(result == "mask me+ please?")

        let failure = BaseTransform.urlDecode.apply(to: "%ZZ")
        switch failure {
        case .success:
            Issue.record("Expected URL decode to fail")
        case .failure(let error):
            #expect(error == .invalidURL)
        }
    }
}
