@testable import NormleLibrary
import SwiftData
import Testing

@MainActor
struct MaskingControllerTests {
    @Test func autoSavePersistsAfterDelay() async throws {
        let context = testContext
        let controller = MaskingController(
            autoSaveDelayNanoseconds: 20_000_000,
            autoSaveSimilarityThreshold: 0.9
        )
        controller.sourceText = "Secret text"

        controller.anonymize(
            context: context,
            options: .init(
                isURLMaskingEnabled: true,
                isEmailMaskingEnabled: true,
                isPhoneMaskingEnabled: true
            ),
            maskRules: [],
            shouldSaveHistory: false,
            isHistoryAutoSaveEnabled: true
        )
        controller.scheduleAutoSave(
            context: context,
            isHistoryAutoSaveEnabled: true
        )

        try await Task.sleep(nanoseconds: 50_000_000)

        let descriptor = FetchDescriptor<TransformRecord>()
        let records = try context.fetch(descriptor)

        #expect(records.count == 1)
        #expect(controller.lastSavedRecord == records.first)
        #expect(records.first?.sourceText == "")
    }

    @Test func autoSaveUpdatesSimilarContent() async throws {
        let context = testContext
        let controller = MaskingController(
            autoSaveDelayNanoseconds: 20_000_000,
            autoSaveSimilarityThreshold: 0.9
        )
        controller.sourceText = "Secret text"

        controller.anonymize(
            context: context,
            options: .init(
                isURLMaskingEnabled: true,
                isEmailMaskingEnabled: true,
                isPhoneMaskingEnabled: true
            ),
            maskRules: [],
            shouldSaveHistory: false,
            isHistoryAutoSaveEnabled: true
        )
        controller.scheduleAutoSave(
            context: context,
            isHistoryAutoSaveEnabled: true
        )

        try await Task.sleep(nanoseconds: 50_000_000)

        // Prepare similar content (case differs, should be considered similar and update existing).
        controller.sourceText = "secret text"
        controller.anonymize(
            context: context,
            options: .init(
                isURLMaskingEnabled: true,
                isEmailMaskingEnabled: true,
                isPhoneMaskingEnabled: true
            ),
            maskRules: [],
            shouldSaveHistory: false,
            isHistoryAutoSaveEnabled: true
        )
        controller.scheduleAutoSave(
            context: context,
            isHistoryAutoSaveEnabled: true
        )

        try await Task.sleep(nanoseconds: 50_000_000)

        let descriptor = FetchDescriptor<TransformRecord>()
        let records = try context.fetch(descriptor)

        #expect(records.count == 1)
        #expect(records.first?.targetText == controller.result?.maskedText)
    }
}
