//
//  NormleAppSessionController.swift
//  Normle
//
//  Created by Codex on 2026/03/21.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import Foundation
import Observation
import SwiftData

@MainActor
@Observable
final class NormleAppSessionController {
    struct PendingAlert {
        let id = UUID()
        let title: String
        let message: String
    }

    private let buildAssembly: @MainActor () -> NormleAppAssembly

    private(set) var assembly: NormleAppAssembly
    private(set) var cloudSyncEnabled: Bool
    private(set) var revision = 0
    private(set) var pendingAlert: PendingAlert?

    init(
        buildAssembly: @escaping @MainActor () -> NormleAppAssembly
    ) {
        self.buildAssembly = buildAssembly

        let assembly = buildAssembly()
        self.assembly = assembly
        cloudSyncEnabled = assembly.isCloudSyncEnabled
    }

    @discardableResult
    func rebuild() -> Bool {
        let assembly = buildAssembly()
        self.assembly = assembly
        cloudSyncEnabled = assembly.isCloudSyncEnabled
        revision += 1
        return cloudSyncEnabled
    }

    @discardableResult
    func rebuildIfNeeded(
        for desiredCloudSyncEnabled: Bool
    ) -> Bool {
        guard desiredCloudSyncEnabled != cloudSyncEnabled else {
            return cloudSyncEnabled
        }

        return rebuild()
    }

    func presentAlert(
        title: String,
        message: String
    ) {
        pendingAlert = .init(
            title: title,
            message: message
        )
    }

    func consumePendingAlert() -> PendingAlert? {
        let pendingAlert = pendingAlert
        self.pendingAlert = nil
        return pendingAlert
    }
}

extension NormleAppSessionController {
    static func live() -> Self {
        .init {
            .live()
        }
    }

    static func preview(
        container: ModelContainer = PreviewData.makeContainer()
    ) -> Self {
        .init {
            .preview(container: container)
        }
    }
}
