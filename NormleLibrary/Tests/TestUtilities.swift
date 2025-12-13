@testable import NormleLibrary
import SwiftData

var testContext: ModelContext {
    .init(
        try! .init(
            for: MaskRecord.self,
            MaskRule.self,
            Tag.self,
            configurations: .init(
                isStoredInMemoryOnly: true
            )
        )
    )
}
