//
//  BaseTransformExtension.swift
//  Normle
//
//  Created by Codex on 2026/03/10.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import Foundation

private enum BaseTransformCodingValues {
    static let rawValueByTransform: [BaseTransform: String] = [
        .fullwidthAlphanumericToHalfwidth: "fullwidthAlphanumericToHalfwidth",
        .halfwidthAlphanumericToFullwidth: "halfwidthAlphanumericToFullwidth",
        .fullwidthSpaceToHalfwidth: "fullwidthSpaceToHalfwidth",
        .halfwidthSpaceToFullwidth: "halfwidthSpaceToFullwidth",
        .halfwidthKatakanaToFullwidth: "halfwidthKatakanaToFullwidth",
        .fullwidthKatakanaToHalfwidth: "fullwidthKatakanaToHalfwidth",
        .lowercase: "lowercase",
        .uppercase: "uppercase",
        .fullwidthDigitsToHalfwidth: "fullwidthDigitsToHalfwidth",
        .halfwidthDigitsToFullwidth: "halfwidthDigitsToFullwidth",
        .base64Encode: "base64Encode",
        .base64Decode: "base64Decode",
        .urlEncode: "urlEncode",
        .urlDecode: "urlDecode",
        .qrEncode: "qrEncode",
        .qrDecode: "qrDecode"
    ]

    static let transformByRawValue = Dictionary(
        uniqueKeysWithValues: rawValueByTransform.map { ($0.value, $0.key) }
    )
}

extension BaseTransform {
    var rawValue: String {
        guard let rawValue = BaseTransformCodingValues.rawValueByTransform[self] else {
            fatalError("Unsupported BaseTransform case.")
        }
        return rawValue
    }

    init?(rawValue: String) {
        guard let transform = BaseTransformCodingValues.transformByRawValue[rawValue] else {
            return nil
        }
        self = transform
    }
}

extension BaseTransform: Codable {
    /// Decodes a transform from its stable raw string identifier.
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        guard let transform = Self(rawValue: rawValue) else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Unsupported BaseTransform raw value: \(rawValue)"
            )
        }
        self = transform
    }

    /// Encodes the transform as its stable raw string identifier.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}
