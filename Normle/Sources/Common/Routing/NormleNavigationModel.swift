//
//  NormleNavigationModel.swift
//  Normle
//
//  Created by Codex on 2026/03/21.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import NormleLibrary
import Observation
import SwiftData
import SwiftUI

@MainActor
@Observable
final class NormleNavigationModel {
    var selectedTab: NormleRootTab = .transforms
    var mappingPath = NavigationPath()
    var historyPath = NavigationPath()
    var settingsPath = NavigationPath()

    func apply(
        _ route: NormleRoute,
        context: ModelContext
    ) {
        switch route {
        case .transforms:
            showTransformsRoot()
        case .mappings:
            showMappingsRoot()
        case .mappingDetail(let id):
            showMappingDetail(
                id: id,
                context: context
            )
        case .history:
            showHistoryRoot()
        case .historyDetail(let id):
            showHistoryDetail(
                id: id,
                context: context
            )
        case .settings:
            showSettingsRoot()
        case .subscription:
            showSubscription()
        case .licenses:
            showLicenses()
        }
    }

    func resetToTransformsRoot() {
        showTransformsRoot()
    }
}

private extension NormleNavigationModel {
    func showTransformsRoot() {
        selectedTab = .transforms
    }

    func showMappingsRoot() {
        selectedTab = .mappings
        mappingPath = .init()
    }

    func showHistoryRoot() {
        selectedTab = .history
        historyPath = .init()
    }

    func showSettingsRoot() {
        selectedTab = .settings
        settingsPath = .init()
    }

    func showSubscription() {
        selectedTab = .settings
        settingsPath = navigationPath(
            appending: [
                NormleSettingsDestination.subscription
            ]
        )
    }

    func showLicenses() {
        selectedTab = .settings
        settingsPath = navigationPath(
            appending: [
                NormleSettingsDestination.subscription,
                NormleSettingsDestination.licenses
            ]
        )
    }

    func showMappingDetail(
        id: String,
        context: ModelContext
    ) {
        selectedTab = .mappings

        guard let rule = resolveModel(
            of: MappingRule.self,
            encodedID: id,
            context: context
        ) else {
            mappingPath = .init()
            return
        }

        mappingPath = navigationPath(
            appending: [
                rule
            ]
        )
    }

    func showHistoryDetail(
        id: String,
        context: ModelContext
    ) {
        selectedTab = .history

        guard let record = resolveModel(
            of: TransformRecord.self,
            encodedID: id,
            context: context
        ) else {
            historyPath = .init()
            return
        }

        historyPath = navigationPath(
            appending: [
                record
            ]
        )
    }

    func navigationPath<Element: Hashable>(
        appending elements: [Element]
    ) -> NavigationPath {
        var path = NavigationPath()
        elements.forEach { element in
            path.append(element)
        }
        return path
    }

    func resolveModel<Model: PersistentModel>(
        of _: Model.Type,
        encodedID: String,
        context: ModelContext
    ) -> Model? {
        guard let identifier = NormlePersistentModelIDCodec.decode(
            encodedID
        ) else {
            return nil
        }

        let descriptor = FetchDescriptor<Model>()

        return try? context.fetch(descriptor).first { candidate in
            candidate.persistentModelID == identifier
        }
    }
}
