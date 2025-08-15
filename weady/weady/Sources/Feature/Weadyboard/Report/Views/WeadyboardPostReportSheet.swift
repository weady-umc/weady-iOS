//
//  WeadyboardPostReportSheet.swift
//  weady
//
//  Created by 엄민서 on 7/17/25.
//

import SwiftUI

struct WeadyboardPostReportSheet: View {
    let boardId: Int
    @ObservedObject var reportViewModel: WeadyboardReportViewModel
    
    var onBack: () -> Void
    var onClose: () -> Void
    var onNextDetail: (ReportReason) -> Void
    var onSelect: (Int) -> Void
    
    private let reasons: [ReportReason] = reportReasons
    
    var body: some View {
        VStack(spacing: 0) {
            WeadyboardPostReportTopBar(showBackButton: true) {
                onClose()
            }
            
            Spacer().frame(height: 24)
            
            // 사유 리스트
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    ForEach(Array(reasons.enumerated()), id: \.offset) { idx, reason in
                        Button {
                            onSelect(idx)
                            onNextDetail(reason)
                        } label: {
                            HStack(spacing: 0) {
                                Text(reason.listTitle)
                                    .fontName(.captionSemibold14)
                                    .foregroundStyle(.black)
                                Spacer()
                                Image("arrow_right")
                                    .resizable()
                                    .frame(width: 6, height: 10)
                            }
                            .padding(.horizontal, 20)
                            .frame(height: 50)
                        }
                        
                        // 구분선
                        Rectangle()
                            .fill(Color.gray600)
                            .frame(height: 1)
                            .padding(.horizontal, 20)
                    }
                }
            }
            .padding(.top, 8)
            Spacer()
        }
        .frame(width: 375, height: 759)
        .background(Color.white100)
    }
}
