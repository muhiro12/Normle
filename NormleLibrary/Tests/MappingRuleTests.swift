import Foundation
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

    @Test func updateAppliesDateAndStatus() throws {
        let context = testContext
        let originalDate = Date(timeIntervalSince1970: 1_700_000_000)
        let updatedDate = Date(timeIntervalSince1970: 1_700_000_100)

        let rule = try MappingRule.create(
            context: context,
            date: originalDate,
            source: "Alpha",
            target: "Alpha-Target",
            isEnabled: true
        )

        try rule.update(
            context: context,
            date: updatedDate,
            source: "Alpha Updated",
            target: "Alpha-Target Updated",
            isEnabled: false
        )

        #expect(rule.date == updatedDate)
        #expect(rule.source == "Alpha Updated")
        #expect(rule.target == "Alpha-Target Updated")
        #expect(rule.isEnabled == false)
    }

    @Test func updateKeepsDateWhenNil() throws {
        let context = testContext
        let originalDate = Date(timeIntervalSince1970: 1_700_000_000)

        let rule = try MappingRule.create(
            context: context,
            date: originalDate,
            source: "Beta",
            target: "Beta-Target",
            isEnabled: true
        )

        try rule.update(
            context: context,
            date: nil,
            source: "Beta Updated",
            target: "Beta-Target Updated",
            isEnabled: true
        )

        #expect(rule.date == originalDate)
    }
}
