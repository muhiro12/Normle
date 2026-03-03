//
//  TransformPreset.swift
//  Normle
//
//  Created by Hiromu Nakano on 2026/03/03.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

public enum TransformPreset: Hashable, Identifiable, Sendable {
    case builtIn(BaseTransform)
    case customMapping

    public static var qrEncode: Self {
        .builtIn(.qrEncode)
    }

    public static var qrDecode: Self {
        .builtIn(.qrDecode)
    }

    public static var allCases: [Self] {
        let builtIns: [Self] = BaseTransform.allCases.map { transform in
            .builtIn(transform) as Self
        }
        return [
            .customMapping
        ] + builtIns
    }

    public var id: String {
        switch self {
        case .builtIn(let transform):
            return "builtIn_\(transform.id)"
        case .customMapping:
            return "customMapping"
        }
    }

    public var title: String {
        switch self {
        case .builtIn(let transform):
            return transform.title
        case .customMapping:
            return String(localized: "Custom")
        }
    }

    public var isQRCodeOnly: Bool {
        switch self {
        case .builtIn(let transform):
            return transform == .qrEncode || transform == .qrDecode
        case .customMapping:
            return false
        }
    }
}
