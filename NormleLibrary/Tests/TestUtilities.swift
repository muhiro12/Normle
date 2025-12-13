@testable import NormleLibrary
import SwiftData

var testContext: ModelContext {
    .init(
        try! .init(
            for: TransformRecord.self,
            MappingRule.self,
            Tag.self,
            configurations: .init(
                isStoredInMemoryOnly: true
            )
        )
    )
}
