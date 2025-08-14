//
//  WeadyboardPostReportDetailView.swift
//  weady
//
//  Created by 엄민서 on 7/17/25.
//

import SwiftUI

struct WeadyboardPostReportDetailView: View {
    let reason: ReportReason
    let selectedReasonIndex: Int
    let boardId: Int
    @State private var customText: String = ""
    @State private var isSubmitting = false
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var reportViewModel: WeadyboardReportViewModel
    @EnvironmentObject private var toast: ToastCenter
    
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
                submitReport()
            } label: {
                Text(isSubmitting ? "신고 중..." : "신고하기")
                    .fontName(.bodySemibold16)
                    .foregroundColor(.white100)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color.black100)
                    .cornerRadius(10)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
            }
            .disabled(isSubmitDisabled)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white100)
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
    }
    
    private var isSubmitDisabled: Bool {
        if isSubmitting { return true }
        if reason.isCustomInput {
            return customText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        return false
    }
    
    private var buttonBackgroundColor: Color {
        isSubmitDisabled ? Color.gray300 : Color.black100
    }
    
    private func submitReport() {
        guard !isSubmitDisabled else { return }
        isSubmitting = true
        
        let reportType = ReportTag.reportTypeEnglish(for: selectedReasonIndex)
        let content = reason.isCustomInput
        ? customText.trimmingCharacters(in: .whitespacesAndNewlines)
        : reason.detailTitle
        
        reportViewModel.report(boardId: boardId, reportType: reportType, content: content) { result in
            isSubmitting = false
            switch result {
            case .success:
                toast.showSuccess("신고가 접수되었습니다.")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    dismiss()
                }
            case .failure:
                toast.showError("신고에 실패했습니다. 잠시 후 다시 시도해주세요.")
            }
        }
    }
}
