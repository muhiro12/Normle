//
//  NormlePersistentModelIDCodec.swift
//  Normle
//
//  Created by Codex on 2026/03/22.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import Foundation
import SwiftData

nonisolated enum NormlePersistentModelIDCodec {
    static func encode(
        _ identifier: PersistentIdentifier
    ) -> String {
        do {
            let data = try JSONEncoder().encode(identifier)
            return data.base64EncodedString()
        } catch {
            assertionFailure(error.localizedDescription)
            return String(describing: identifier)
        }
    }

    static func decode(
        _ value: String
    ) -> PersistentIdentifier? {
        guard let data = Data(base64Encoded: value) else {
            return nil
        }

        return try? JSONDecoder().decode(
            PersistentIdentifier.self,
            from: data
        )
    }

    static func isValid(
        _ value: String
    ) -> Bool {
        decode(value) != nil
    }
}
