//
//  SelectableTextView.swift
//  Normle
//
//  Created by Hiromu Nakano on 2026/03/03.
//  Copyright © 2026 Hiromu Nakano. All rights reserved.
//

import SwiftUI
#if os(iOS)
import UIKit
#endif

struct SelectableTextView: View {
    #if os(iOS)
    private final class UIKitCoordinator: NSObject, UITextViewDelegate {
        private var parent: PlatformTextView

        init(parent: PlatformTextView) {
            self.parent = parent
        }

        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
            parent.updateSelectedText(from: textView)
        }

        func textViewDidChangeSelection(_ textView: UITextView) {
            parent.updateSelectedText(from: textView)
        }
    }

    private final class SelectableTextViewUITextView: UITextView {
        var onCreateMapping: ((String) -> Void)?

        override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
            if action == #selector(createMapping) {
                return selectedTextRange?.isEmpty == false
            }
            return super.canPerformAction(action, withSender: sender)
        }

        @objc
        private func createMapping() {
            guard let range = selectedTextRange,
                  let selection = text(in: range) else {
                return
            }
            let trimmedSelection = selection.trimmingCharacters(in: .whitespacesAndNewlines)
            guard trimmedSelection.isEmpty == false else {
                return
            }
            onCreateMapping?(trimmedSelection)
        }

        override func editMenu(
            for _: UITextRange,
            suggestedActions: [UIMenuElement]
        ) -> UIMenu? {
            guard selectedTextRange?.isEmpty == false else {
                return UIMenu(children: suggestedActions)
            }
            let action = UIAction(title: String(localized: "Create mapping")) { [weak self] _ in
                self?.createMapping()
            }
            return UIMenu(children: [action] + suggestedActions)
        }
    }

    private struct PlatformTextView: UIViewRepresentable {
        @Binding var text: String
        @Binding var selectedText: String
        let onCreateMapping: ((String) -> Void)?

        func makeUIView(context: Context) -> UITextView {
            let textView = SelectableTextViewUITextView()
            textView.delegate = context.coordinator
            textView.font = UIFont.preferredFont(forTextStyle: .body)
            textView.isEditable = true
            textView.isScrollEnabled = true
            textView.backgroundColor = .clear
            textView.text = text
            textView.onCreateMapping = onCreateMapping
            return textView
        }

        func updateUIView(_ uiView: UITextView, context _: Context) {
            if uiView.text != text {
                uiView.text = text
            }
            updateSelectedText(from: uiView)
        }

        func makeCoordinator() -> UIKitCoordinator {
            .init(parent: self)
        }

        func updateSelectedText(from textView: UITextView) {
            guard let selectionRange = textView.selectedTextRange else {
                if selectedText.isEmpty == false {
                    selectedText = String()
                }
                return
            }
            let selection = textView.text(in: selectionRange) ?? String()
            if selection != selectedText {
                selectedText = selection
            }
        }
    }
    #else
    private final class AppKitCoordinator: NSObject, NSTextViewDelegate {
        private var parent: PlatformTextView

        init(parent: PlatformTextView) {
            self.parent = parent
        }

        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else {
                return
            }
            parent.text = textView.string
            parent.updateSelectedText(from: textView)
        }

        func textViewDidChangeSelection(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else {
                return
            }
            parent.updateSelectedText(from: textView)
        }
    }

    private struct PlatformTextView: NSViewRepresentable {
        @Binding var text: String
        @Binding var selectedText: String
        let onCreateMapping: ((String) -> Void)?

        func makeNSView(context: Context) -> NSScrollView {
            let textView = NSTextView()
            textView.isEditable = true
            textView.isSelectable = true
            textView.isRichText = false
            textView.importsGraphics = false
            textView.allowsImageEditing = false
            textView.textColor = .labelColor
            textView.insertionPointColor = .labelColor
            if #available(macOS 15, *) {
                textView.drawsBackground = false
            } else {
                textView.drawsBackground = true
                textView.backgroundColor = .textBackgroundColor
            }
            textView.font = .preferredFont(forTextStyle: .body)
            textView.delegate = context.coordinator
            textView.string = text

            let scrollView = NSScrollView()
            scrollView.hasVerticalScroller = true
            scrollView.documentView = textView
            return scrollView
        }

        func updateNSView(_ nsView: NSScrollView, context _: Context) {
            guard let textView = nsView.documentView as? NSTextView else {
                return
            }
            if textView.string != text {
                textView.string = text
            }
            updateSelectedText(from: textView)
        }

        func makeCoordinator() -> AppKitCoordinator {
            .init(parent: self)
        }

        func updateSelectedText(from textView: NSTextView) {
            let range = textView.selectedRange()
            guard let selectionRange = Range(range, in: textView.string) else {
                if selectedText.isEmpty == false {
                    selectedText = String()
                }
                return
            }
            let selection = String(textView.string[selectionRange])
            if selection != selectedText {
                selectedText = selection
            }
        }
    }
    #endif

    @Binding var text: String
    @Binding var selectedText: String
    let onCreateMapping: ((String) -> Void)?

    var body: some View {
        PlatformTextView(
            text: $text,
            selectedText: $selectedText,
            onCreateMapping: onCreateMapping
        )
    }
}
