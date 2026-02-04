//
//  SelectableTextEditor.swift
//
//
//  Created by Hiromu Nakano on 2025/11/23.
//

import SwiftUI
#if os(iOS)
import UIKit
#endif

struct SelectableTextEditor: View {
    @Binding var text: String
    @Binding var selectedText: String
    let onCreateMapping: ((String) -> Void)?

    var body: some View {
        SelectableTextView(
            text: $text,
            selectedText: $selectedText,
            onCreateMapping: onCreateMapping
        )
        .liquidGlassEffect()
    }
}

#if os(iOS)
private struct SelectableTextView: UIViewRepresentable {
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

    func makeCoordinator() -> Coordinator {
        .init(parent: self)
    }

    private func updateSelectedText(from textView: UITextView) {
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

    final class Coordinator: NSObject, UITextViewDelegate {
        private var parent: SelectableTextView

        init(parent: SelectableTextView) {
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

    final class SelectableTextViewUITextView: UITextView {
        var onCreateMapping: ((String) -> Void)?

        override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
            if action == #selector(createMapping) {
                return selectedTextRange?.isEmpty == false
            }
            return super.canPerformAction(action, withSender: sender)
        }

        @objc private func createMapping() {
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
}
#else
private struct SelectableTextView: NSViewRepresentable {
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

    func makeCoordinator() -> Coordinator {
        .init(parent: self)
    }

    private func updateSelectedText(from textView: NSTextView) {
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

    final class Coordinator: NSObject, NSTextViewDelegate {
        private var parent: SelectableTextView

        init(parent: SelectableTextView) {
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
}
#endif
