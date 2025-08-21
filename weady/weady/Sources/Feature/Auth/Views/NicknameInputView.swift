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
    @AppStorage("nickname") private var storedNickname: String = ""

    private let agreements: [OnboardingAgreement]

    // 통합 플로우 모드
    var embeddedInFlow: Bool = false
    var onNext: ((String) -> Void)? = nil

    @MainActor
    init(
        agreements: [OnboardingAgreement],
        embeddedInFlow: Bool = false,
        onNext: ((String) -> Void)? = nil,
        viewModel: NicknameInputViewModel? = nil
    ) {
        self.agreements = agreements
        self.embeddedInFlow = embeddedInFlow
        self.onNext = onNext
        if let viewModel {
            _vm = StateObject(wrappedValue: viewModel)
        } else {
            _vm = StateObject(wrappedValue: NicknameInputViewModel())
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if !embeddedInFlow {
                ProgressIndicator(currentStep: 0, totalSteps: 5)
            }

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

            // 입력
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

                Rectangle()
                    .frame(height: 1)
                    .foregroundStyle(Color.gray200)

                if vm.shouldShowValidationError {
                    if vm.nickname.isEmpty {
                        Text("최소 2자 이상 입력해 주세요.")
                            .font(.caption).foregroundColor(.red)
                    } else if !vm.isValidNickname {
                        Text("한글, 영문과 숫자로 2~15자 이내로 입력해 주세요.")
                            .font(.caption).foregroundColor(.red)
                    }
                }
                if let msg = vm.dupCheckMessage {
                    Text(msg).font(.caption).foregroundColor(.red)
                }
            }
            .padding(.horizontal, 32)
            .padding(.top, 52)

            Spacer()

            Button {
                let name = vm.nickname.trimmingCharacters(in: .whitespacesAndNewlines)
                storedNickname = name
                vm.next()
                if vm.shouldNavigateNext {
                    onNext?(vm.nickname) // 통합 플로우 콜백
                }
            } label: {
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
        }
        .onAppear {
            print("DEBUG Nickname →", agreements.map { "\($0.termsType)=\($0.isAgreed)" })
        }
    }
}
