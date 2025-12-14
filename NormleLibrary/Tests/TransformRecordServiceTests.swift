@testable import NormleLibrary
import SwiftData
import XCTest

final class TransformRecordServiceTests: XCTestCase {
    func testSavingRecordsPersistsSourceAndTargetText() throws {
        let context = testContext
        let mapping = Mapping(
            original: "secret",
            masked: "Alias(1)",
            kind: .other,
            occurrenceCount: 2
        )

        let first = try TransformRecordService.saveRecord(
            context: context,
            sourceText: "",
            targetText: "masked-1",
            mappings: [mapping]
        )

        let descriptor = FetchDescriptor<TransformRecord>(
            sortBy: [
                .init(\.date, order: .reverse)
            ]
        )
        let records = try context.fetch(descriptor)

        XCTAssertEqual(records.count, 1)
        XCTAssertEqual(records.first, first)
        XCTAssertEqual(records.first?.sourceText, "")
        XCTAssertEqual(records.first?.targetText, "masked-1")
    }
}
