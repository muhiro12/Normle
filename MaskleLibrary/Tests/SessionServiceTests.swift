@testable import MaskleLibrary
import SwiftData
import XCTest

final class SessionServiceTests: XCTestCase {
    func testSavingSessionsStoresMappings() throws {
        let context = testContext
        let mapping = Mapping(
            original: "secret",
            alias: "Alias(1)",
            kind: .other,
            occurrenceCount: 2
        )

        let first = try SessionService.saveSession(
            context: context,
            maskedText: "masked-1",
            note: "first",
            mappings: [mapping]
        )
        XCTAssertEqual(first.mappings?.count, 1)

        let descriptor = FetchDescriptor<MaskingSession>(
            sortBy: [
                .init(\.createdAt, order: .reverse)
            ]
        )
        let sessions = try context.fetch(descriptor)

        XCTAssertEqual(sessions.count, 1)
        XCTAssertEqual(sessions.first?.maskedText, "masked-1")
    }
}
