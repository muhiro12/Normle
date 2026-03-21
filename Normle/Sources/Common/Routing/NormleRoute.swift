//
//  NormleRoute.swift
//  Normle
//
//  Created by Codex on 2026/03/21.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import Foundation
import MHPlatform
import SwiftData

nonisolated enum NormleRoute: Hashable, Sendable, MHDeepLinkRoute {
    case transforms
    case mappings
    case mappingDetail(id: String)
    case history
    case historyDetail(id: String)
    case settings
    case subscription
    case licenses

    nonisolated var deepLinkDescriptor: MHDeepLinkDescriptor {
        switch self {
        case .transforms:
            return .init(pathComponents: ["transforms"])
        case .mappings:
            return .init(pathComponents: ["mappings"])
        case .mappingDetail(let id):
            return .init(pathComponents: ["mappings", id])
        case .history:
            return .init(pathComponents: ["history"])
        case .historyDetail(let id):
            return .init(pathComponents: ["history", id])
        case .settings:
            return .init(pathComponents: ["settings"])
        case .subscription:
            return .init(pathComponents: ["settings", "subscription"])
        case .licenses:
            return .init(pathComponents: ["settings", "licenses"])
        }
    }

    nonisolated init?(
        deepLinkDescriptor: MHDeepLinkDescriptor
    ) {
        let detailPathComponentCount = 2

        switch deepLinkDescriptor.pathComponents {
        case ["transforms"]:
            self = .transforms
        case ["mappings"]:
            self = .mappings
        case let components
                where components.count == detailPathComponentCount
                && components[0] == "mappings"
                && NormlePersistentModelIDCodec.isValid(components[1]):
            self = .mappingDetail(id: components[1])
        case ["history"]:
            self = .history
        case let components
                where components.count == detailPathComponentCount
                && components[0] == "history"
                && NormlePersistentModelIDCodec.isValid(components[1]):
            self = .historyDetail(id: components[1])
        case ["settings"]:
            self = .settings
        case ["settings", "subscription"]:
            self = .subscription
        case ["settings", "licenses"]:
            self = .licenses
        default:
            return nil
        }
    }
}
