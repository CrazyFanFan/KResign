//
//  LogView.swift
//  KResign
//
//  Created by Crazy凡 on 2021/8/21.
//

import SwiftUI

struct LogView: NSViewRepresentable {

    @Binding var append: NSAttributedString?

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSTextView.scrollableTextView()

        if let textView = scrollView.documentView as? NSTextView {
            textView.isEditable = false
            textView.isSelectable = true
        }
        scrollView.hasVerticalScroller = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let append = append else { return }
        self.append = nil

        if let textView = scrollView.documentView as? NSTextView {
            textView.textStorage?.append(append)

            if let storage = textView.textStorage, storage.length > 0 {
                textView.scrollRangeToVisible(NSRange(location: storage.length - 1, length: 1))
            }
        }
    }

//    func makeCoordinator() -> Coordinator {
//        Coordinator($append)
//    }
//
//    class Coordinator: NSObject, NSTextViewDelegate {
//        var text: Binding<NSAttributedString?>
//
//        init(_ text: Binding<NSAttributedString?>) {
//            self.text = text
//        }
//
//        func textViewDidChange(_ textView: NSTextView) {
//            self.text.wrappedValue = textView.attributedString()
//        }
//    }
}

struct Logview_Previews: PreviewProvider {
    static var previews: some View {
        LogView(append: .constant(nil))
    }
}
