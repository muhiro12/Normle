@testable import NormleLibrary
import XCTest

final class MaskingSimilarityTests: XCTestCase {
    func testIdenticalStringsAreFullySimilar() {
        let score = MaskingSimilarity.similarityScore(
            between: "Normle",
            and: "Normle"
        )

        XCTAssertEqual(score, 1.0)
    }

    func testMinorDifferenceRemainsHighlySimilar() {
        let score = MaskingSimilarity.similarityScore(
            between: "Client A project",
            and: "Client A Project"
        )

        XCTAssertGreaterThanOrEqual(score, 0.9)
    }

    func testDifferentStringsAreDissimilar() {
        let score = MaskingSimilarity.similarityScore(
            between: "Client A",
            and: "PrivateURL(1)"
        )

        XCTAssertLessThan(score, 0.5)
    }
}
