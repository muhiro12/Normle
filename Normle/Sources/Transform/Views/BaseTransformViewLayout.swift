//
//  BaseTransformViewLayout.swift
//  Normle
//
//  Created by Hiromu Nakano on 2026/03/10.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import SwiftUI

enum BaseTransformViewLayout {
    static let horizontalPadding = 16.0
    static let listRowSpacing = 16.0
    static let compactInset = 16.0
    static let wideInset = 24.0
    static let iOSRowInsets = EdgeInsets(
        top: compactInset,
        leading: compactInset,
        bottom: compactInset,
        trailing: compactInset
    )
    static let macOSRowInsets = EdgeInsets(
        top: compactInset,
        leading: wideInset,
        bottom: compactInset,
        trailing: wideInset
    )

    static var sectionRowInsets: EdgeInsets {
        #if os(macOS)
        return macOSRowInsets
        #else
        return iOSRowInsets
        #endif
    }
}
