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

    @Test func schemaVersionRemainsStable() {
        #expect(NormleSchemaV1.versionIdentifier == .init(1, 0, 0))
        #expect(
            NormleSchemaV1.models.map { String(describing: $0) }.sorted() == [
                "MappingRule",
                "Tag",
                "TransformRecord"
            ]
        )
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

    @Test func userPreferencesDecodeKeepsDefaultsForMissingFields() throws {
        let payload = """
        {
          "version": 1,
          "maskingPreferences": {
            "isURLMaskingEnabled": false
          },
          "presetSelection": {
            "caseTransform": "uppercase"
          }
        }
        """
        let data = try #require(payload.data(using: .utf8))

        let decoded = UserPreferences.decode(from: data)

        #expect(decoded.maskingPreferences.isURLMaskingEnabled == false)
        #expect(decoded.maskingPreferences.isEmailMaskingEnabled)
        #expect(decoded.maskingPreferences.isPhoneMaskingEnabled)
        #expect(decoded.presetSelection.caseTransform == .uppercase)
        #expect(decoded.presetSelection.isCustomMappingEnabled == false)
        #expect(decoded.presetSelection.base64Transform == nil)
    }

    @Test func userPreferencesDecodeIgnoresUnknownTransformRawValue() throws {
        let payload = """
        {
          "version": 1,
          "maskingPreferences": {
            "isURLMaskingEnabled": true,
            "isEmailMaskingEnabled": true,
            "isPhoneMaskingEnabled": true
          },
          "presetSelection": {
            "caseTransform": "notExistingTransform"
          }
        }
        """
        let data = try #require(payload.data(using: .utf8))

        let decoded = UserPreferences.decode(from: data)

        #expect(decoded.presetSelection.caseTransform == nil)
    }

    @Test func mappingDecodeSupportsLegacyKeys() throws {
        let payload = """
        {
          "source": "Alice",
          "target": "Person A",
          "kind": "person",
          "count": 2
        }
        """
        let data = try #require(payload.data(using: .utf8))

        let decoded = try JSONDecoder().decode(Mapping.self, from: data)

        #expect(decoded.original == "Alice")
        #expect(decoded.masked == "Person A")
        #expect(decoded.kind == .person)
        #expect(decoded.occurrenceCount == 2)
    }

    @Test func mappingEncodeUsesCurrentContractKeys() throws {
        let mapping = Mapping(
            id: UUID(uuidString: "11111111-2222-3333-4444-555555555555") ?? .init(),
            original: "Alice",
            masked: "Person A",
            kind: .person,
            occurrenceCount: 3
        )

        let data = try JSONEncoder().encode(mapping)
        let object = try #require(
            JSONSerialization.jsonObject(
                with: data
            ) as? [String: Any]
        )

        #expect(object["original"] as? String == "Alice")
        #expect(object["masked"] as? String == "Person A")
        #expect(object["occurrenceCount"] as? Int == 3)
        #expect(object["source"] == nil)
        #expect(object["target"] == nil)
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
