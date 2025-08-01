//
//  NicknameInputView.swift
//  weady
//
//  Created by 김영택 on 8/1/25.
//

import SwiftUI

struct NicknameInputView: View {
    @StateObject private var vm = NicknameInputViewModel()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 진행 인디케이터
            ProgressIndicator(currentStep: 0, totalSteps: 5)
            
            // 제목
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 0) {
                    Text("가입을 축하드려요!")
                        .fontName(.titleBold24)
                    Text(" 🎉")
                        .fontName(.metaSemibold21)
                }
                
                Text("어떻게 불러드리면 될까요?")
                    .fontName(.titleBold24)
            }
            .padding(.horizontal, 32)
            .padding(.top, 39)
            
            // 닉네임 입력 필드
            VStack(alignment: .leading, spacing: 12) {
                //닉네임 입력하면 사라짐
                
                Text("닉네임 입력")
                    .fontName(.bodyRegular16)
                    .foregroundStyle(Color.black100)
                    .opacity(vm.nickname.isEmpty ? 1 : 0)
                
                
                Rectangle()
                    .frame(height: 1)
                    .foregroundStyle(Color.gray200)
                    .overlay(
                        TextField("", text: $vm.nickname)
                            .font(AppTextStyle.bodyRegular16.font)
                            .textFieldStyle(.plain)
                            .padding(.horizontal, 0)
                            .padding(.vertical, 0)
                            .padding(.bottom, 12)
                        , alignment: .bottomLeading
                    )
            }
            .padding(.horizontal, 32)
            .padding(.top, 52)
            
            Spacer().frame(height: 444)
            
            // 다음버튼
            Button { vm.next() } label: {
                Text("다음")
                    .fontName(.bodyMedium16)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 11)
                    .background(vm.canProceed ? Color.black100 : Color.gray800)
                    .foregroundStyle(Color.white100)
                    .cornerRadius(10)
            }
            .disabled(!vm.canProceed)
            .padding(.horizontal, 20)
            .padding(.bottom, 22)
        }
        .fullScreenCover(isPresented: $vm.shouldNavigateNext) {
            PreferenceInputView(nickname: vm.nickname)
        }
    }
}


#Preview {
    NicknameInputView()
}
