@testable import MaskleLibrary
import SwiftData
import XCTest

@MainActor
final class MaskingControllerTests: XCTestCase {
    func testAutoSavePersistsAfterDelay() async throws {
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
            manualRules: [],
            shouldSaveHistory: false,
            isHistoryAutoSaveEnabled: true
        )
        controller.scheduleAutoSave(
            context: context,
            isHistoryAutoSaveEnabled: true
        )

        try await Task.sleep(nanoseconds: 50_000_000)

        let descriptor = FetchDescriptor<MaskingSession>()
        let sessions = try context.fetch(descriptor)

        XCTAssertEqual(sessions.count, 1)
        XCTAssertEqual(controller.lastSavedSession, sessions.first)
    }

    func testAutoSaveUpdatesSimilarContent() async throws {
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
            manualRules: [],
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
            manualRules: [],
            shouldSaveHistory: false,
            isHistoryAutoSaveEnabled: true
        )
        controller.scheduleAutoSave(
            context: context,
            isHistoryAutoSaveEnabled: true
        )

        try await Task.sleep(nanoseconds: 50_000_000)

        let descriptor = FetchDescriptor<MaskingSession>()
        let sessions = try context.fetch(descriptor)

        XCTAssertEqual(sessions.count, 1)
        XCTAssertEqual(sessions.first?.maskedText, controller.result?.maskedText)
    }
}
