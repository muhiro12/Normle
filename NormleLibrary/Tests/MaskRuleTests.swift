@testable import NormleLibrary
import XCTest

final class MaskRuleTests: XCTestCase {
    func testCreateRejectsDuplicateOriginal() throws {
        let context = testContext

        _ = try MaskRule.create(
            context: context,
            original: "Apple",
            masked: "A社"
        )

        XCTAssertThrowsError(
            try MaskRule.create(
                context: context,
                original: "Apple",
                masked: "B社"
            )
        ) { error in
            XCTAssertEqual(error as? MaskRuleError, .duplicateOriginal)
        }
    }

    func testUpdateRejectsDuplicateMasked() throws {
        let context = testContext

        _ = try MaskRule.create(
            context: context,
            original: "Apple",
            masked: "A社"
        )
        let ruleToUpdate = try MaskRule.create(
            context: context,
            original: "Orange",
            masked: "C社"
        )

        XCTAssertThrowsError(
            try ruleToUpdate.update(
                context: context,
                original: "Orange",
                masked: "A社",
                isEnabled: true
            )
        ) { error in
            XCTAssertEqual(error as? MaskRuleError, .duplicateMasked)
        }
    }
}
