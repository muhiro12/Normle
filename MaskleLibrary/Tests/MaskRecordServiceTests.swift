@testable import MaskleLibrary
import SwiftData
import XCTest

final class MaskRecordServiceTests: XCTestCase {
    func testSavingRecordsPersistsMaskedText() throws {
        let context = testContext
        let mapping = Mapping(
            original: "secret",
            alias: "Alias(1)",
            kind: .other,
            occurrenceCount: 2
        )

        let first = try MaskRecordService.saveRecord(
            context: context,
            maskedText: "masked-1",
            mappings: [mapping]
        )

        let descriptor = FetchDescriptor<MaskRecord>(
            sortBy: [
                .init(\.date, order: .reverse)
            ]
        )
        let records = try context.fetch(descriptor)

        XCTAssertEqual(records.count, 1)
        XCTAssertEqual(records.first, first)
        XCTAssertEqual(records.first?.maskedText, "masked-1")
    }
}
