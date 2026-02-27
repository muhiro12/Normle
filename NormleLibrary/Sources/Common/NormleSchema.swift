//
//  NormleSchema.swift
//
//
//  Created by Hiromu Nakano on 2026/02/27.
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

public enum NormleSchemaMigrationPlan: SchemaMigrationPlan {
    public static var schemas: [any VersionedSchema.Type] {
        [NormleSchemaV1.self]
    }

    public static var stages: [MigrationStage] {
        []
    }
}
