//
//  LabeledRow.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 27.05.2026.
//

import SwiftUI

struct LabeledRow<Content: View>: View {
    let title: String
    let titleWidth: CGFloat
    let content: Content
    
    init(title: String,
         titleWidth: CGFloat = 120,
         @ViewBuilder content: () -> Content) {
        self.title = title
        self.titleWidth = titleWidth
        self.content = content()
    }
    
    var body: some View {
        HStack {
            Text(title)
                .frame(width: titleWidth, alignment: .leading)
            content
            Spacer()
        }
        .padding(.horizontal)
    }
}
