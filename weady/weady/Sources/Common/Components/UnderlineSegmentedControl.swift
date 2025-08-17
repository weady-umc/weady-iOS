//
//  UnderlineSegmentedControl.swift
//  weady
//
//  Created by Yoonseo on 8/17/25.
//


import SwiftUI

struct UnderlineSegmentedControl<Item: Hashable>: View {
    let items: [Item]
    @Binding var selection: Item
    var title: (Item) -> String

    var body: some View {
        HStack(spacing: 0) {
            ForEach(items, id: \.self) { item in
                Button {
                    withAnimation(.easeInOut(duration: 0.15)) { selection = item }
                } label: {
                    VStack(spacing: 8) {
                        Text(title(item))
                            .foregroundStyle(selection == item ? Color.gray100 : Color.gray800)
                            .fontName(.headingRegular20)

                        Rectangle()
                            .fill(selection == item ? Color.gray100 : Color.gray800)
                            .frame(width: 59, height: 1.5)
                    }
                    .contentShape(Rectangle())
                    
                }
                .buttonStyle(.plain)
            }
            Spacer(minLength: 0)
        }
        .padding(.leading, 0)
        .padding(.top, 5)
    }
}
