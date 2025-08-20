//
//  StartView.swift
//  weady
//
//  Created by 김영택 on 8/6/25.
//

import SwiftUI

extension StartView {
    static func onboarding(
        nickname: String,
        gender: GenderCode?,
        styleIds: [Int64]?,
        agreements: [OnboardingAgreement]?
    ) -> StartView {
        StartView(nickname: nickname, gender: gender, styleIds: styleIds, agreements: agreements)
    }
}

struct StartView: View {
    @Environment(\.router) private var router
    @EnvironmentObject private var onboarding: OnboardingStore
    @StateObject private var vm: StartViewModel
    @State private var showHome = false
    
    @State private var selectedTab: TabType = .home
    @State private var isTabBarHidden: Bool = false

    // 전체 데이터 전달용 (POST에 쓰일 값)
    init(
          nickname: String,
          gender: GenderCode? = nil,
          styleIds: [Int64]? = nil,
          agreements: [OnboardingAgreement]? = nil
      ) {
          _vm = StateObject(
              wrappedValue: StartViewModel(
                  nickname: nickname,
                  gender: gender,
                  styleIds: styleIds,
                  agreements: agreements
              )
          )
      }
    
    // 덩어리 텍스트: ‘닉네임+님’은 붙이고(줄바꿈 금지), 나머지는 자연스럽게 감기게
    private var composedTitle: Text {
        Text("앞으로 웨디가\n")
        + Text(verbatim: vm.nickname).bold()
        + Text("\u{2060}님").bold()
        + Text("의 취향에 맞는 하루를 ")
        + Text("추천해드릴게요.")
    }
    
    // 닉네임이 짧으면 한 줄, 길면 자연스럽게 2줄
    @ViewBuilder
    private func titleBlock() -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("취향 입력이 완료되었어요 !")
                .fontName(.titleBold24)
                .foregroundStyle(Color.black100)

            Spacer().frame(height: 25)

            composedTitle
                .fontName(.titleMedium24)      // ⬅️ 전체 기본 폰트 한 번만
                .foregroundStyle(Color.black100)
                .multilineTextAlignment(.leading)
                .lineLimit(4)
                .fixedSize(horizontal: false, vertical: true)
                .allowsTightening(true)
        }
    }

    @ViewBuilder
    private func primaryButton() -> some View {
        Button {
            vm.startTapped()
        } label: {
            Text("웨디 시작하기")
                .fontName(.bodyMedium16)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 11)
                .background(Color.black100)
                .foregroundStyle(Color.white100)
                .cornerRadius(10)
        }
        .disabled(vm.isSubmitting)
        .padding(.bottom, 22)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ProgressIndicator(currentStep: 4, totalSteps: 5)
            Spacer().frame(height:39)
            titleBlock()
                .padding(.horizontal, 32)
            Spacer()
            primaryButton()
                .padding(.horizontal, 20)
        }
        .toolbar(.hidden, for: .navigationBar)
        .onChange(of: vm.navigateHome) { _, go in
            guard go else { return }
            router.reset(to: .basetab)
            onboarding.reset()
        }
    }
}

#Preview("StartView – Onboarding") {
    let router = NavigationRouter()
    let store = OnboardingStore()
    StartView.onboarding(
        nickname: "영택",
        gender: nil,
        styleIds: nil,
        agreements: nil
    )
    .environment(router)
    .environmentObject(store)
}
