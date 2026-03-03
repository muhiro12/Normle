//
//  Tag.swift
//  Normle
//
//  Created by Hiromu Nakano on 2025/11/23.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import Foundation
import SwiftData

/// A lightweight tag that annotates mask rules or records.
@Model
public final class Tag {
    /// The display name of the tag.
    public private(set) var name = String()
    /// The raw tag type identifier persisted in storage.
    public private(set) var typeID = TagType.maskRule.rawValue

    private init() {}

    /// Creates or returns an existing tag with the given `name` and `type`.
    public static func create(
        context: ModelContext,
        name: String,
        type: TagType
    ) throws -> Tag {
        let typeID = type.rawValue
        var descriptor = FetchDescriptor<Tag>(
            predicate: #Predicate<Tag> { tag in
                tag.name == name && tag.typeID == typeID
            }
        )
        descriptor.fetchLimit = 1
        if let existing = try context.fetch(descriptor).first {
            return existing
        }

        let tag = Tag()
        context.insert(tag)
        tag.name = name
        tag.typeID = type.rawValue
        return tag
    }

    /// Testing helper: creates a tag without checking duplicates.
    public static func createIgnoringDuplicates(
        context: ModelContext,
        name: String,
        type: TagType
    ) -> Tag {
        let tag = Tag()
        context.insert(tag)
        tag.name = name
        tag.typeID = type.rawValue
        return tag
    }
}

public extension Tag {
    /// The typed tag category resolved from the stored raw value.
    var type: TagType? {
        TagType(rawValue: typeID)
    }
}

extension Tag: Hashable {
    public static func == (lhs: Tag, rhs: Tag) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
