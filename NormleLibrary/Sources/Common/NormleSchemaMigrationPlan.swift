//
//  NormleSchemaMigrationPlan.swift
//  Normle
//
//  Created by Hiromu Nakano on 2026/03/03.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import SwiftData

public enum NormleSchemaMigrationPlan: SchemaMigrationPlan {
    public static var schemas: [any VersionedSchema.Type] {
        [NormleSchemaV1.self]
    }

    public static var stages: [MigrationStage] {
        []
    }
}
