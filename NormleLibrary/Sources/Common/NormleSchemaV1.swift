//
//  NormleSchemaV1.swift
//  Normle
//
//  Created by Hiromu Nakano on 2026/02/27.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import SwiftData

public enum NormleSchemaV1: VersionedSchema {
    public static var versionIdentifier: Schema.Version {
        .init(1, 0, 0)
    }

    public static var models: [any PersistentModel.Type] {
        [
            TransformRecord.self,
            MappingRule.self,
            Tag.self
        ]
    }
}
