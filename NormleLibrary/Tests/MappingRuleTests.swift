@testable import NormleLibrary
import XCTest

final class MappingRuleTests: XCTestCase {
    func testCreateRejectsDuplicateSource() throws {
        let context = testContext

        _ = try MappingRule.create(
            context: context,
            source: "Apple",
            target: "A社"
        )

        XCTAssertThrowsError(
            try MappingRule.create(
                context: context,
                source: "Apple",
                target: "B社"
            )
        ) { error in
            XCTAssertEqual(error as? MappingRuleError, .duplicateSource)
        }
    }

    func testUpdateRejectsDuplicateTarget() throws {
        let context = testContext

        _ = try MappingRule.create(
            context: context,
            source: "Apple",
            target: "A社"
        )
        let ruleToUpdate = try MappingRule.create(
            context: context,
            source: "Orange",
            target: "C社"
        )

        XCTAssertThrowsError(
            try ruleToUpdate.update(
                context: context,
                source: "Orange",
                target: "A社",
                isEnabled: true
            )
        ) { error in
            XCTAssertEqual(error as? MappingRuleError, .duplicateTarget)
        }
    }
}
