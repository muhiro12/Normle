@testable import NormleLibrary
import Testing

struct MappingRuleTests {
    @Test func createRejectsDuplicateSource() throws {
        let context = testContext

        _ = try MappingRule.create(
            context: context,
            source: "Apple",
            target: "A社"
        )

        #expect(throws: MappingRuleError.duplicateSource) {
            try MappingRule.create(
                context: context,
                source: "Apple",
                target: "B社"
            )
        }
    }

    @Test func updateRejectsDuplicateTarget() throws {
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

        #expect(throws: MappingRuleError.duplicateTarget) {
            try ruleToUpdate.update(
                context: context,
                source: "Orange",
                target: "A社",
                isEnabled: true
            )
        }
    }
}
