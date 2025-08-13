//
//  TermsAgreementView.swift
//  weady
//
//  Created by 김영택 on 7/31/25.
//

import SwiftUI

struct TermsAgreementView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = TermsAgreementViewModel()
    
    @State private var showNicknameInput = false
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("서비스 이용약관")
                .fontName(.titleBold24)
                .foregroundStyle(Color.black100)
                .padding(.top, 25)
                .padding(.bottom, 36)
                .padding(.horizontal, 10)
            
            // 모두 동의
            Button {
                viewModel.toggleAll(!viewModel.isAllSelected)
            } label: {
                HStack {
                    Image(viewModel.isAllSelected ? "darkCheck" : "lightCheck")
                        .resizable().aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                        .padding(.trailing, 10)
                    Text("모두 동의")
                        .fontName(.bodySemibold16)
                        .foregroundStyle(Color.black100)
                }
                .padding(.bottom, 10)
            }
            .padding(.horizontal, 10)
            
            Divider()
                .padding(.horizontal, 13)
                .padding(.bottom, 22)
            
            // 개별 항목
            ForEach($viewModel.items) { $item in
                Button {
                    item.isOn.toggle()
                } label: {
                    HStack {
                        Image(item.isOn ? "darkCheck" : "lightCheck")
                            .resizable().aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                            .padding(.trailing, 10)
                        Text(item.label)
                            .fontName(.bodyRegular16)
                            .foregroundStyle(Color.black100)
                    }
                    .padding(.bottom, 22)
                }
                .padding(.horizontal, 10)
            }
            
            Spacer()
            
            // 다음
            Button {
                showNicknameInput = true
            } label: {
                Text("다음")
                    .font(.system(size: 16, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(viewModel.requiredAgreed ? Color.black100 : Color.gray800)
                    .foregroundStyle(Color.white)
                    .cornerRadius(10)
            }
            .disabled(!viewModel.requiredAgreed)
            .padding(.bottom, 22)
            
        }
        .padding(.horizontal, 20)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        
        .fullScreenCover(isPresented: $showNicknameInput) {
            NicknameInputView(agreements: viewModel.makeAgreementsPayload())
                .onAppear {
                    let p = viewModel.makeAgreementsPayload()
                    print("DEBUG Sheet Payload →", p.map { "\($0.termsType)=\($0.isAgreed)" })
                }
        }
    }
}

#Preview { TermsAgreementView() }
