//
//  WeadyboardPostReportDetailView.swift
//  weady
//
//  Created by 엄민서 on 7/17/25.
//

import SwiftUI

struct WeadyboardPostReportDetailView: View {
    let reason: ReportReason
    @State private var customText: String = ""
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
           
            WeadyboardPostReportTopBar(showBackButton: true) {
                dismiss()
            }
            
            Spacer().frame(height: 34)
            
            Text(reason.detailTitle)
                .fontName(.headingSemibold20)
                .foregroundColor(.black100)
            
            if reason.isCustomInput {
                ZStack(alignment: .topLeading) {
                    TextEditor(text: $customText)
                        .fontName(.captionRegular14)
                        .frame(height: 155)
                        .padding(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray500)
                        )
                        .padding(.top, 32)
                        .padding(.horizontal, 20)
                    
                    if customText.isEmpty {
                        Text("불편하셨던 이유를 남겨주세요.")
                            .fontName(.captionRegular14)
                            .foregroundColor(.gray200)
                            .padding(.top, 48)
                            .padding(.leading, 32)
                    }
                }
                    
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    Text("해당되는 콘텐츠:")
                        .fontName(.bodyMedium16)
                        .padding(.bottom, 10)
                    
                    ForEach(reason.details, id: \.self) { detail in
                        HStack(alignment: .top, spacing: 6) {
                            Text("•")
                                .fontName(.captionMedium14)
                                .padding(.top, 2)
                            Text(detail)
                                .fontName(.captionMedium14)
                        }
                        .padding(.leading, 10)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 35)
                .padding(.leading, 20)
            }
            
            Spacer()
            
            Button {

            } label: {
                Text("신고하기")
                    .fontName(.bodySemibold16)
                    .foregroundColor(.white100)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color.black100)
                    .cornerRadius(10)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white100)
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
    }
}
