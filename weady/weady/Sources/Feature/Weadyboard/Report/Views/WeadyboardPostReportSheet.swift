//
//  WeadyboardPostReportSheet.swift
//  weady
//
//  Created by 엄민서 on 7/17/25.
//

import SwiftUI

struct WeadyboardPostReportSheet: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        VStack(spacing: 0) {
            
            WeadyboardPostReportTopBar()

            ForEach(reportReasons, id: \.id) { reason in
                NavigationLink(value: reason) {
                    HStack {
                        Text(reason.listTitle)
                            .fontName(.captionSemibold14)
                            .foregroundColor(.black100)
                        Spacer()
                        Image("arrow_right")
                            .resizable()
                            .frame(width: 6, height: 10)
                    }
                    .padding(.horizontal, 20)
                    .frame(height: 50)
                }
                Rectangle()
                    .fill(Color.gray600)
                    .frame(height: 1)
                    .padding(.horizontal, 20)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white100)
    }
}
