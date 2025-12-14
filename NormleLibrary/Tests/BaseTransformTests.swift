@testable import NormleLibrary
import Testing

struct BaseTransformTests {
    @Test func fullwidthAlphanumericToHalfwidth() {
        let input = "ＡＢＣ１２３"
        let result = BaseTransform.fullwidthAlphanumericToHalfwidth.apply(to: input)
        #expect(result == "ABC123")
    }

    @Test func halfwidthAlphanumericToFullwidth() {
        let input = "ABC123"
        let result = BaseTransform.halfwidthAlphanumericToFullwidth.apply(to: input)
        #expect(result == "ＡＢＣ１２３")
    }

    @Test func lowercaseAndUppercase() {
        #expect(BaseTransform.lowercase.apply(to: "AbC") == "abc")
        #expect(BaseTransform.uppercase.apply(to: "AbC") == "ABC")
    }

    @Test func digitConversion() {
        #expect(BaseTransform.fullwidthDigitsToHalfwidth.apply(to: "１２３") == "123")
        #expect(BaseTransform.halfwidthDigitsToFullwidth.apply(to: "123") == "１２３")
    }

    @Test func spaceConversion() {
        #expect(BaseTransform.fullwidthSpaceToHalfwidth.apply(to: "a　b") == "a b")
        #expect(BaseTransform.halfwidthSpaceToFullwidth.apply(to: "a b") == "a　b")
    }

    @Test func katakanaConversion() {
        let input = "ｶﾀｶﾅ"
        let result = BaseTransform.halfwidthKatakanaToFullwidth.apply(to: input)
        #expect(result == "カタカナ")
    }
}
