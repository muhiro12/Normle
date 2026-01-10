//
//  SelectableTextEditor.swift
//
//
//  Created by Hiromu Nakano on 2025/11/23.
//

import SwiftUI

struct SelectableTextEditor: View {
    @Binding var text: String
    @Binding var selectedText: String

    var body: some View {
        SelectableTextView(
            text: $text,
            selectedText: $selectedText
        )
    }
}

#if os(iOS)
private struct SelectableTextView: UIViewRepresentable {
    @Binding var text: String
    @Binding var selectedText: String

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.isEditable = true
        textView.isScrollEnabled = true
        textView.backgroundColor = .clear
        textView.text = text
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
}
#else
private struct SelectableTextView: NSViewRepresentable {
    @Binding var text: String
    @Binding var selectedText: String

    func makeNSView(context: Context) -> NSScrollView {
        let textView = NSTextView()
        textView.isEditable = true
        textView.isSelectable = true
        textView.drawsBackground = false
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
