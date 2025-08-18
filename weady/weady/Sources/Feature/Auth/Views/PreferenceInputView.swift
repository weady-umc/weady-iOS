//
//  PreferenceInputView.swift
//  weady
//
//  Created by 김영택 on 8/1/25.
//

import SwiftUI

struct PreferenceInputView: View {
    @StateObject private var vm: PreferenceInputViewModel
    @Environment(\.router) private var router
    @EnvironmentObject private var onboarding: OnboardingStore
    
    private let agreements: [OnboardingAgreement]
    // 기본값 제공
    init(
        nickname: String,
        agreements: [OnboardingAgreement],
        viewModel: PreferenceInputViewModel? = nil
    ) {
        self.agreements = agreements
        if let viewModel {
            _vm = StateObject(wrappedValue: viewModel)
        } else {
            _vm = StateObject(wrappedValue: PreferenceInputViewModel(nickname: nickname))
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 1) 프로그레스 인디케이터 (2번째 스텝)
            ProgressIndicator(currentStep: 1, totalSteps: 5)
            
            // 2) 타이틀: 언더라인된 닉네임 + 나머지 텍스트
            VStack(alignment: .leading, spacing: 18) {
                HStack(spacing: 0) {
                    Text(vm.nickname)
                        .fontName(.titleBold24)
                        .foregroundStyle(Color.black100)
                    Text("님의 취향을 알고싶어요!")
                        .fontName(.titleBold24)
                        .foregroundStyle(Color.black100)
                }
                Text("내 정보를 입력하면\n웨디가 조금 더 맞춤형 추천을 드릴 수 있어요 :)")
                    .fontName(.metaMedium12)
                    .foregroundStyle(Color.gray900)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false,
                               vertical: true)
            }
            .padding(.horizontal, 32)
            .padding(.top, 39)
            
            Spacer()
            
            Spacer().frame(height: 146)
            
            // 4) 하단 버튼들
            VStack(spacing: 20) {
                Button{
                    router.push(.start)
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
                
                Button{
                    router.push(.gender)
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
            .onAppear {
                // 디버그: View가 들고 있는 약관을 확인
                print("DEBUG Preference →", agreements.map { "\($0.termsType)=\($0.isAgreed)" })
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    let router = NavigationRouter()
    let store = OnboardingStore()
    NavigationStack {
        PreferenceInputView(
            nickname: "영택",
            agreements: PreviewAgreements.requiredAllAgreed
        )
    }
    .environment(router)
    .environmentObject(store)
}
