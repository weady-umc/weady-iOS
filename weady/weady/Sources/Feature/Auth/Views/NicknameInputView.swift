//
//  NicknameInputView.swift
//  weady
//
//  Created by 김영택 on 8/1/25.
//

import SwiftUI

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

struct NicknameInputView: View {
    @StateObject private var vm: NicknameInputViewModel
    @FocusState private var isFocused: Bool
    
    private let agreements: [OnboardingAgreement]
    // 기본값 제공
    @MainActor
      init(
          agreements: [OnboardingAgreement],
          viewModel: NicknameInputViewModel? = nil
      ) {
          self.agreements = agreements
          if let viewModel {
              _vm = StateObject(wrappedValue: viewModel)
          } else {
              _vm = StateObject(wrappedValue: NicknameInputViewModel())
          }
      }
    
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
            
            // MARK: - 닉네임 입력 필드 (수동 플레이스홀더)
            VStack(alignment: .leading, spacing: 0) {
                TextField("", text: $vm.nickname)
                    .focused($isFocused)
                    .placeholder(when: vm.nickname.isEmpty && !isFocused) {
                        Text("닉네임 입력")
                            .font(AppTextStyle.bodyRegular16.font)
                            .foregroundColor(Color.black100)
                    }
                    .font(AppTextStyle.bodyRegular16.font)
                    .foregroundColor(Color.black100)
                    .padding(.vertical, 12)
                
                // 2) 밑줄
                Rectangle()
                    .frame(height: 1)
                    .foregroundStyle(Color.gray200)
                
                // 3) 유효성 검사 에러 메시지
                if vm.shouldShowValidationError {
                    if vm.nickname.isEmpty {
                        Text("최소 2자 이상 입력해 주세요.")
                            .font(.caption)
                            .foregroundColor(.red)
                    } else if !vm.isValidNickname {
                        Text("한글, 영문과 숫자로 2~15자 이내로 입력해 주세요.")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            }
            .padding(.horizontal, 32)
            .padding(.top, 52)
            
            Spacer()
            
            // 다음버튼
            Button { vm.next() } label: {
                Text("다음")
                    .fontName(.bodyMedium16)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 11)
                    .background(Color.black100)
                    .foregroundStyle(Color.white100)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 22)
        }//VStack End
        .onAppear {
            // 디버그: View가 보관한 agreements 확인
            print("DEBUG Nickname →", agreements.map { "\($0.termsType)=\($0.isAgreed)" })
        }
        // 다음 화면으로 agreements를 "View에서" 전달
        .fullScreenCover(isPresented: $vm.shouldNavigateNext) {
            // agreements 릴레이
            PreferenceInputView(nickname: vm.nickname, agreements: agreements)
        }
    }
}

/*#Preview {
    NicknameInputView()
}
*/
