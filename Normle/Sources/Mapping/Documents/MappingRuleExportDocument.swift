//
//  MappingRuleExportDocument.swift
//
//
//  Created by Hiromu Nakano on 2025/11/23.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct MappingRuleExportDocument: FileDocument {
    static var readableContentTypes: [UTType] {
        [.json]
    }

    static var writableContentTypes: [UTType] {
        [.json]
    }

    var data: Data

    init(data: Data) {
        self.data = data
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.data = data
    }

    func fileWrapper(
        configuration _: WriteConfiguration
    ) -> FileWrapper {
        .init(regularFileWithContents: data)
    }
}
