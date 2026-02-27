import Foundation
@testable import NormleLibrary
import SwiftData
import Testing

struct CompatibilityContractTests {
    @Test func boolAppStorageKeysRemainStable() {
        #expect(BoolAppStorageKey.isSubscribeOn.rawValue == "m5k3I8s9")
        #expect(BoolAppStorageKey.isICloudOn.rawValue == "c1o9U2d4")
        #expect(BoolAppStorageKey.isURLMaskingEnabled.rawValue == "f3R8q1L0")
        #expect(BoolAppStorageKey.isEmailMaskingEnabled.rawValue == "K9m4T2s7")
        #expect(BoolAppStorageKey.isPhoneMaskingEnabled.rawValue == "p6V1x8N3")
    }

    @Test func dataAppStorageKeysRemainStable() {
        #expect(DataAppStorageKey.userPreferences.rawValue == "U9r3E7p2")
    }

    @Test func userPreferencesVersionRemainsStable() {
        #expect(UserPreferences.currentVersion == 1)
    }

    @Test func mappingKindRawValuesRemainStable() {
        let expectedRawValues = [
            "person",
            "company",
            "project",
            "url",
            "email",
            "phone",
            "other",
            "custom"
        ]
        #expect(MappingKind.allCases.map(\.rawValue) == expectedRawValues)
    }

    @Test func tagTypeRawValuesRemainStable() {
        #expect(TagType.maskRule.rawValue == "5f4c06c9")
        #expect(TagType.maskRecord.rawValue == "c2b7a1e8")
    }

    @Test func baseTransformRawValuesRemainStable() {
        let expectedRawValues = [
            "fullwidthAlphanumericToHalfwidth",
            "halfwidthAlphanumericToFullwidth",
            "fullwidthSpaceToHalfwidth",
            "halfwidthSpaceToFullwidth",
            "halfwidthKatakanaToFullwidth",
            "fullwidthKatakanaToHalfwidth",
            "lowercase",
            "uppercase",
            "fullwidthDigitsToHalfwidth",
            "halfwidthDigitsToFullwidth",
            "base64Encode",
            "base64Decode",
            "urlEncode",
            "urlDecode",
            "qrEncode",
            "qrDecode"
        ]
        #expect(BaseTransform.allCases.map(\.rawValue) == expectedRawValues)
    }

    @Test func mappingRuleTransferExportVersionRemainsStable() throws {
        let context = try makeContext()
        try MappingRule.create(
            context: context,
            source: "source",
            target: "target"
        )

        let data = try MappingRuleTransferService.exportData(context: context)
        let envelope = try JSONDecoder().decode(
            TransferEnvelope.self,
            from: data
        )

        #expect(envelope.version == 2)
        #expect(envelope.rules.count == 1)
        #expect(envelope.rules.first?.source == "source")
        #expect(envelope.rules.first?.target == "target")
    }
}

private extension CompatibilityContractTests {
    struct TransferEnvelope: Decodable {
        let version: Int
        let rules: [TransferRule]
    }

    struct TransferRule: Decodable {
        let source: String
        let target: String
    }

    func makeContext() throws -> ModelContext {
        let container = try ModelContainer(
            for: MappingRule.self,
            Tag.self,
            configurations: .init(isStoredInMemoryOnly: true)
        )
        return .init(container)
    }
}
