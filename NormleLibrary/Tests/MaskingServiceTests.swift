@testable import NormleLibrary
import XCTest

final class MaskingServiceTests: XCTestCase {
    func testAnonymizeAppliesMaskRulesAndAutomaticDetection() {
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

        XCTAssertTrue(result.maskedText.contains("Client A"))
        XCTAssertFalse(result.maskedText.contains("A株式会社"))
        XCTAssertTrue(result.maskedText.contains("Email(1)"))
        XCTAssertTrue(result.maskedText.contains("Phone(1)"))
        XCTAssertTrue(result.maskedText.contains("PrivateURL(1)"))

        XCTAssertEqual(result.mappings.count, 4)

        let company = result.mappings.first {
            $0.kind == .company
        }
        XCTAssertEqual(company?.masked, "Client A")
        XCTAssertEqual(company?.occurrenceCount, 1)

        let email = result.mappings.first {
            $0.kind == .email
        }
        XCTAssertEqual(email?.masked, "Email(1)")
        XCTAssertEqual(email?.occurrenceCount, 1)

        let phone = result.mappings.first {
            $0.kind == .phone
        }
        XCTAssertEqual(phone?.masked, "Phone(1)")
        XCTAssertEqual(phone?.occurrenceCount, 1)

        let url = result.mappings.first {
            $0.kind == .url
        }
        XCTAssertEqual(url?.masked, "PrivateURL(1)")
        XCTAssertEqual(url?.occurrenceCount, 1)
    }
}
