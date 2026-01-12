@testable import NormleLibrary
import Testing

struct MappingRuleDraftTests {
    @Test func canSaveIsFalseWhenSourceIsEmpty() {
        let draft = MappingRuleDraft(
            sourceText: "   ",
            targetText: "Target",
            isEnabled: true
        )

        #expect(draft.canSave == false)
    }

    @Test func canSaveIsFalseWhenTargetIsEmpty() {
        let draft = MappingRuleDraft(
            sourceText: "Source",
            targetText: "   ",
            isEnabled: true
        )

        #expect(draft.canSave == false)
    }

    @Test func applyThrowsWhenSourceIsEmpty() {
        let context = testContext
        let draft = MappingRuleDraft(
            sourceText: "   ",
            targetText: "Target",
            isEnabled: true
        )

        #expect(throws: MappingRuleDraftError.missingSource) {
            try draft.apply(
                context: context,
                to: nil
            )
        }
    }

    @Test func applyThrowsWhenTargetIsEmpty() {
        let context = testContext
        let draft = MappingRuleDraft(
            sourceText: "Source",
            targetText: "   ",
            isEnabled: true
        )

        #expect(throws: MappingRuleDraftError.missingTarget) {
            try draft.apply(
                context: context,
                to: nil
            )
        }
    }

    @Test func applyCreatesRuleWithNormalizedTexts() throws {
        let context = testContext
        let draft = MappingRuleDraft(
            sourceText: "  Source  ",
            targetText: " Target ",
            isEnabled: false
        )

        let rule = try draft.apply(
            context: context,
            to: nil
        )

        #expect(rule.source == "Source")
        #expect(rule.target == "Target")
        #expect(rule.isEnabled == false)
    }

    @Test func applyUpdatesExistingRule() throws {
        let context = testContext
        let rule = try MappingRule.create(
            context: context,
            source: "Old Source",
            target: "Old Target",
            isEnabled: true
        )
        let draft = MappingRuleDraft(
            sourceText: "New Source",
            targetText: "New Target",
            isEnabled: false
        )

        let updatedRule = try draft.apply(
            context: context,
            to: rule
        )

        #expect(updatedRule === rule)
        #expect(rule.source == "New Source")
        #expect(rule.target == "New Target")
        #expect(rule.isEnabled == false)
    }
}
