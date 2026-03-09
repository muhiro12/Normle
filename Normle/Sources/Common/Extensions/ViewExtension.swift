//
//  ViewExtension.swift
//  Normle
//
//  Created by Hiromu Nakano on 2026/02/04.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import SwiftUI

extension View {
    @ViewBuilder
    func liquidGlassButtonStyle() -> some View {
        if #available(iOS 26, macOS 26, *) {
            self.buttonStyle(.glass)
        } else {
            self
        }
    }

    @ViewBuilder
    func liquidGlassProminentButtonStyle() -> some View {
        if #available(iOS 26, macOS 26, *) {
            self.buttonStyle(.glassProminent)
        } else {
            self
        }
    }

    @ViewBuilder
    func liquidGlassEffect(
        cornerRadius: CGFloat = 16
    ) -> some View {
        if #available(iOS 26, macOS 26, *) {
            self.glassEffect(
                .regular.interactive(),
                in: RoundedRectangle(
                    cornerRadius: cornerRadius,
                    style: .continuous
                )
            )
        } else {
            self
        }
    }

    @ViewBuilder
    func liquidGlassTextFieldStyle() -> some View {
        if #available(iOS 26, macOS 26, *) {
            self.textFieldStyle(.automatic)
        } else {
            self.textFieldStyle(.roundedBorder)
        }
    }

    @ViewBuilder
    func secondaryActionStyle() -> some View {
        #if os(macOS)
        self.buttonStyle(.borderless)
        #else
        self.buttonStyle(.bordered)
        #endif
    }

    @ViewBuilder
    func primaryActionStyle() -> some View {
        #if os(macOS)
        self.buttonStyle(.borderedProminent)
            .controlSize(.regular)
        #else
        self.buttonStyle(.borderedProminent)
        #endif
    }
}
