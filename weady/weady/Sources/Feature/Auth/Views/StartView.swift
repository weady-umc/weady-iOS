//
//  StartView.swift
//  weady
//
//  Created by 김영택 on 8/6/25.
//

import SwiftUI

struct StartView: View {
    @Environment(\.router) private var router
    @EnvironmentObject var homeRouter: HomeRouter
    
    @StateObject private var vm: StartViewModel
    
    var onFinish: (() -> Void)? = nil
    @State private var didFinish = false

    init(
        nickname: String,
        gender: GenderCode? = nil,
        styleIds: [Int64]? = nil,
        agreements: [OnboardingAgreement]? = nil,
        onFinish: (() -> Void)? = nil
    ) {
        _vm = StateObject(
            wrappedValue: StartViewModel(
                nickname: nickname,
                gender: gender,
                styleIds: styleIds,
                agreements: agreements
            )
        )
        self.onFinish = onFinish
    }

    private var composedTitle: Text {
        Text("앞으로 웨디가\n")
        + Text(verbatim: vm.nickname).bold()
        + Text("\u{2060}님").bold()
        + Text("의 취향에 맞는 하루를 ")
        + Text("추천해드릴게요.")
    }

    @ViewBuilder
    private func titleBlock() -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("취향 입력이 완료되었어요 !")
                .fontName(.titleBold24)
                .foregroundStyle(Color.black100)
            Spacer().frame(height: 25)
            composedTitle
                .fontName(.titleMedium24)
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
        .allowsHitTesting(!vm.isSubmitting) 
        .padding(.bottom, 22)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer().frame(height: 39)
            titleBlock()
                .padding(.horizontal, 32)
            Spacer()

            primaryButton()
                .padding(.horizontal, 20)
        }
        .onChange(of: vm.navigateHome) { _, go in
            guard go, !didFinish else { return }
            didFinish = true
            OnboardingStateStore.shared.markAllCompleted()
            onFinish?()
        }
    }
}
