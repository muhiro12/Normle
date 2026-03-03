//
//  BaseTransformError.swift
//  Normle
//
//  Created by Hiromu Nakano on 2026/03/03.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import Foundation

public enum BaseTransformError: LocalizedError, Equatable {
    case invalidBase64
    case invalidURL
    case qrNotDetected
    case qrGenerationFailed

    public var errorDescription: String? {
        switch self {
        case .invalidBase64:
            "Failed to decode Base64 text."
        case .invalidURL:
            "Failed to process URL text."
        case .qrNotDetected:
            "Failed to detect a QR code."
        case .qrGenerationFailed:
            "Failed to generate a QR code."
        }
    }
}
