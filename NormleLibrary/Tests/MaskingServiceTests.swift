@testable import NormleLibrary
import Testing

struct MaskingServiceTests {
    @Test func anonymizeAppliesMaskRulesAndAutomaticDetection() {
        let options = MaskingOptions(
            isURLMaskingEnabled: true,
            isEmailMaskingEnabled: true,
            isPhoneMaskingEnabled: true
        )

        let maskRules = [
            MaskingRule(
                original: "A株式会社",
                masked: "Client A",
                kind: .company
            )
        ]

        let source = """
        A株式会社の担当は山田太郎です。連絡はjohn@example.comか+1-555-1234にお願いします。詳細はhttps://internal.example.com/pathをご覧ください。
        """

        let result = MaskingService.anonymize(
            text: source,
            maskRules: maskRules,
            options: options
        )

        #expect(result.maskedText.contains("Client A"))
        #expect(result.maskedText.contains("A株式会社") == false)
        #expect(result.maskedText.contains("Email(1)"))
        #expect(result.maskedText.contains("Phone(1)"))
        #expect(result.maskedText.contains("PrivateURL(1)"))

        #expect(result.mappings.count == 4)

        let company = result.mappings.first {
            $0.kind == .company
        }
        #expect(company?.masked == "Client A")
        #expect(company?.occurrenceCount == 1)

        let email = result.mappings.first {
            $0.kind == .email
        }
        #expect(email?.masked == "Email(1)")
        #expect(email?.occurrenceCount == 1)

        let phone = result.mappings.first {
            $0.kind == .phone
        }
        #expect(phone?.masked == "Phone(1)")
        #expect(phone?.occurrenceCount == 1)

        let url = result.mappings.first {
            $0.kind == .url
        }
        #expect(url?.masked == "PrivateURL(1)")
        #expect(url?.occurrenceCount == 1)
    }

    @Test func anonymizeSkipsAutomaticMaskingWhenDisabled() {
        let options = MaskingOptions(
            isURLMaskingEnabled: false,
            isEmailMaskingEnabled: false,
            isPhoneMaskingEnabled: false
        )

        let source = """
        Contact john@example.com, +1-555-1234, or https://internal.example.com/path
        """

        let result = MaskingService.anonymize(
            text: source,
            maskRules: [],
            options: options
        )

        #expect(result.maskedText == source)
        #expect(result.mappings.isEmpty)
    }

    @Test func anonymizeAppliesManualRulesEvenWhenAutomaticDisabled() {
        let options = MaskingOptions(
            isURLMaskingEnabled: false,
            isEmailMaskingEnabled: false,
            isPhoneMaskingEnabled: false
        )
        let maskRules = [
            MaskingRule(
                original: "Secret",
                masked: "Alias",
                kind: .custom
            )
        ]

        let result = MaskingService.anonymize(
            text: "Secret message",
            maskRules: maskRules,
            options: options
        )

        #expect(result.maskedText.contains("Alias"))
        #expect(result.maskedText.contains("Secret") == false)
        #expect(result.mappings.count == 1)
    }
}
