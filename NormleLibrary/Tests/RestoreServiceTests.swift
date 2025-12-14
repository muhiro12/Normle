@testable import NormleLibrary
import Testing

struct RestoreServiceTests {
    @Test func restoreRevertsMaskedText() {
        let mappings = [
            Mapping(
                original: "A株式会社",
                masked: "Client A",
                kind: .company,
                occurrenceCount: 1
            ),
            Mapping(
                original: "john@example.com",
                masked: "Email(1)",
                kind: .email,
                occurrenceCount: 1
            ),
            Mapping(
                original: "+1-555-1234",
                masked: "Phone(1)",
                kind: .phone,
                occurrenceCount: 1
            ),
            Mapping(
                original: "https://internal.example.com/path",
                masked: "PrivateURL(1)",
                kind: .url,
                occurrenceCount: 1
            )
        ]

        let masked = "Client Aへの連絡はEmail(1)かPhone(1)まで。詳細はPrivateURL(1)に記載しています。"

        let restored = RestoreService.restore(
            text: masked,
            mappings: mappings
        )

        #expect(restored.contains("A株式会社"))
        #expect(restored.contains("john@example.com"))
        #expect(restored.contains("+1-555-1234"))
        #expect(restored.contains("https://internal.example.com/path"))
    }
}
