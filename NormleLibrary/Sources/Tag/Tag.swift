//
//  Tag.swift
//
//
//  Created by Hiromu Nakano on 2025/11/23.
//

import Foundation
import SwiftData

/// A lightweight tag that annotates mask rules or records.
@Model
public final class Tag {
    public private(set) var name = String()
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
