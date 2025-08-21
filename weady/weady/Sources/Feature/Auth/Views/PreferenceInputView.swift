//
//  PreferenceInputView.swift
//  weady
//
//  Created by 김영택 on 8/1/25.
//

import SwiftUI

func nameWithHonorific(_ nickname: String) -> Text {
    let safe = nickname + "\u{2060}님"
    return Text(verbatim: safe)
}

struct PreferenceInputView: View {
    @StateObject private var vm: PreferenceInputViewModel

    private let agreements: [OnboardingAgreement]

    // 통합 플로우 모드
    var embeddedInFlow: Bool = false
    var onSkip: (() -> Void)? = nil
    var onNext: (() -> Void)? = nil

    init(
        nickname: String,
        agreements: [OnboardingAgreement],

        embeddedInFlow: Bool = false,
        onSkip: (() -> Void)? = nil,
        onNext: (() -> Void)? = nil,
        viewModel: PreferenceInputViewModel? = nil
    ) {
        self.agreements = agreements
        self.embeddedInFlow = embeddedInFlow
        self.onSkip = onSkip
        self.onNext = onNext
        if let viewModel {
            _vm = StateObject(wrappedValue: viewModel)
        } else {
            _vm = StateObject(wrappedValue: PreferenceInputViewModel(nickname: nickname))
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if !embeddedInFlow {
                ProgressIndicator(currentStep: 1, totalSteps: 5)
            }

            VStack(alignment: .leading, spacing: 18) {
                (
                    Text(verbatim: vm.nickname)
                    + Text("\u{2060}님")
                    + Text("의 취향을 알고싶어요!")
                )
                .fontName(.titleBold24)
                .foregroundStyle(Color.black100)

                Text("내 정보를 입력하면\n웨디가 조금 더 맞춤형 추천을 드릴 수 있어요 :)")
                    .fontName(.metaMedium12)
                    .foregroundStyle(Color.gray900)
            }
            .padding(.horizontal, 32)
            .padding(.top, 39)
            
            Spacer()
            
            Spacer().frame(height: 146)

            VStack(spacing: 20) {
                Button {
                    vm.skip()
                    if vm.didTapSkip {
                        onSkip?() // 통합 플로우 콜백
                    }
                } label: {
                    Text("취향입력 건너뛰기")
                        .fontName(.bodyMedium16)
                        .foregroundStyle(Color.gray800)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 11)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray800, lineWidth: 1)
                        )
                }

                Button {
                    vm.next()
                    if vm.didTapNext {
                        onNext?() // 통합 플로우 콜백
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

            }
            .padding(.horizontal, 20)
            .padding(.bottom, 22)
        }
        /*        .onAppear {
         // 디버그: View가 들고 있는 약관을 확인
         print("DEBUG Preference →", agreements.map { "\($0.termsType)=\($0.isAgreed)" })
         }
         // 스킵 → StartView (agreements 그대로 전달)
         .fullScreenCover(isPresented: $vm.didTapSkip) {
         StartView(
         nickname: vm.nickname,
         gender: nil,                 // 아직 성별 없음
         styleIds: [],                // 스킵이므로 빈 배열
         agreements: agreements       // 약관 릴레이
         )
         }
         // 다음 → GenderSelection (agreements 그대로 전달)
         .fullScreenCover(isPresented: $vm.didTapNext) {
         GenderSelectionView(nickname: vm.nickname, agreements: agreements)
         
         
         }
         .padding(.horizontal, 20)
         .padding(.bottom, 22)
         
         }
         */
        .onAppear {
            print("DEBUG Preference →", agreements.map { "\($0.termsType)=\($0.isAgreed)" })
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
    }
    
}

