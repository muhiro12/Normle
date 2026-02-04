//
//  LiquidGlassModifiers.swift
//
//
//  Created by Hiromu Nakano on 2026/02/04.
//

import SwiftUI

extension View {
    @ViewBuilder
    func liquidGlassButtonStyle() -> some View {
        if #available(iOS 18, macOS 26, *) {
            self.buttonStyle(.glass)
        } else {
            self
        }
    }

    @ViewBuilder
    func liquidGlassProminentButtonStyle() -> some View {
        if #available(iOS 18, macOS 26, *) {
            self.buttonStyle(.glassProminent)
        } else {
            self
        }
    }

    @ViewBuilder
    func liquidGlassEffect(
        cornerRadius: CGFloat = 16
    ) -> some View {
        if #available(iOS 18, macOS 26, *) {
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
        if #available(iOS 18, macOS 26, *) {
            self.textFieldStyle(.automatic)
        } else {
            self.textFieldStyle(.roundedBorder)
        }
    }
}
