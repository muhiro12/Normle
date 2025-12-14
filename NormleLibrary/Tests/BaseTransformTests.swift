@testable import NormleLibrary
import XCTest

final class BaseTransformTests: XCTestCase {
    func testFullwidthAlphanumericToHalfwidth() {
        let input = "ＡＢＣ１２３"
        let result = BaseTransform.fullwidthAlphanumericToHalfwidth.apply(to: input)
        XCTAssertEqual(result, "ABC123")
    }

    func testHalfwidthAlphanumericToFullwidth() {
        let input = "ABC123"
        let result = BaseTransform.halfwidthAlphanumericToFullwidth.apply(to: input)
        XCTAssertEqual(result, "ＡＢＣ１２３")
    }

    func testLowercaseAndUppercase() {
        XCTAssertEqual(BaseTransform.lowercase.apply(to: "AbC"), "abc")
        XCTAssertEqual(BaseTransform.uppercase.apply(to: "AbC"), "ABC")
    }

    func testDigitConversion() {
        XCTAssertEqual(BaseTransform.fullwidthDigitsToHalfwidth.apply(to: "１２３"), "123")
        XCTAssertEqual(BaseTransform.halfwidthDigitsToFullwidth.apply(to: "123"), "１２３")
    }

    func testSpaceConversion() {
        XCTAssertEqual(BaseTransform.fullwidthSpaceToHalfwidth.apply(to: "a　b"), "a b")
        XCTAssertEqual(BaseTransform.halfwidthSpaceToFullwidth.apply(to: "a b"), "a　b")
    }

    func testKatakanaConversion() {
        let input = "ｶﾀｶﾅ"
        let result = BaseTransform.halfwidthKatakanaToFullwidth.apply(to: input)
        XCTAssertEqual(result, "カタカナ")
    }
}
