@testable import NormleLibrary
import Testing

struct MaskingSimilarityTests {
    @Test func identicalStringsAreFullySimilar() {
        let score = MaskingSimilarity.similarityScore(
            between: "Normle",
            and: "Normle"
        )

        #expect(score == 1.0)
    }

    @Test func minorDifferenceRemainsHighlySimilar() {
        let score = MaskingSimilarity.similarityScore(
            between: "Client A project",
            and: "Client A Project"
        )

        #expect(score >= 0.9)
    }

    @Test func differentStringsAreDissimilar() {
        let score = MaskingSimilarity.similarityScore(
            between: "Client A",
            and: "PrivateURL(1)"
        )

        #expect(score < 0.5)
    }
}
