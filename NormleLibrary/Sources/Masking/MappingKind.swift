//
//  MappingKind.swift
//  Normle
//
//  Created by Hiromu Nakano on 2025/11/23.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import Foundation

public enum MappingKind: String, Codable, CaseIterable, Identifiable, Sendable {
    case person
    case company
    case project
    case url
    case email
    case phone
    case other
    case custom

    public var id: String {
        rawValue
    }

    public var displayName: String {
        switch self {
        case .person:
            "Person"
        case .company:
            "Company"
        case .project:
            "Project"
        case .url:
            "URL"
        case .email:
            "Email"
        case .phone:
            "Phone"
        case .other:
            "Other"
        case .custom:
            "Custom"
        }
    }

    public var aliasPrefix: String {
        switch self {
        case .person:
            "Person"
        case .company:
            "Client"
        case .project:
            "Project"
        case .url:
            "PrivateURL"
        case .email:
            "Email"
        case .phone:
            "Phone"
        case .other:
            "Alias"
        case .custom:
            "Alias"
        }
    }
}
