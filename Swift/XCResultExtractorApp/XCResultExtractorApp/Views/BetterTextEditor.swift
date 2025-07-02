//
//  BetterTextEditor.swift
//  XCResultExtractorApp
//
//  Created by Chris Mash on 02/07/2025.
//

import SwiftUI

// https://stackoverflow.com/a/76132466
struct BetterTextEditor: NSViewRepresentable {
    
    @Binding var text: String
    let editable: Bool
    
    var textView = NSTextView.scrollableTextView()
    
    func makeNSView(context: Context) -> NSScrollView {
        let documentView = textView.documentView as! NSTextView
        documentView.backgroundColor = .textBackgroundColor
        documentView.delegate = context.coordinator
        documentView.isEditable = editable
        let paragraphStyle: NSMutableParagraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        paragraphStyle.lineSpacing = 4
        documentView.defaultParagraphStyle = paragraphStyle
        
        // TODO: is this necessary? textview already has a scroll bar?
        let scroll = NSScrollView()
        scroll.hasVerticalScroller = true
        scroll.documentView = documentView
        scroll.drawsBackground = false
        
        return scroll
    }

    func updateNSView(_ view: NSScrollView,
                      context: Context) {
        guard let documentView = view.documentView as? NSTextView else {
            return
        }
        
        documentView.string = text
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, NSTextViewDelegate{
        
        var parent: BetterTextEditor
        
        init(_ parent: BetterTextEditor) {
            self.parent = parent
        }
        
        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else {
                return
            }
            
            self.parent.text = textView.string
        }
        
        func textView(_ textView: NSTextView,
                      shouldChangeTextIn affectedCharRange: NSRange,
                      replacementString: String?) -> Bool {
            return true
        }
        
    }
    
}

#Preview("editable") {
    @Previewable @State var text: String = .loremIpsum
    BetterTextEditor(text: $text,
                     editable: true)
}

#Preview("not editable") {
    BetterTextEditor(text: .constant(.loremIpsum),
                     editable: false)
}
