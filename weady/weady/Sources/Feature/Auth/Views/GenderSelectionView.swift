//
//  GenderSelectionView.swift
//  weady
//
//  Created by 김영택 on 8/1/25.
//

import SwiftUI

struct GenderSelectionView: View {
    @StateObject private var vm: GenderSelectionViewModel
    private let agreements: [OnboardingAgreement]

    // 통합 플로우 모드
    var embeddedInFlow: Bool = false
    var onSkip: (() -> Void)? = nil
    var onNext: ((GenderCode?) -> Void)? = nil

    init(
        nickname: String,
        agreements: [OnboardingAgreement],
        embeddedInFlow: Bool = false,
        onSkip: (() -> Void)? = nil,
        onNext: ((GenderCode?) -> Void)? = nil
    ) {
        _vm = StateObject(wrappedValue: GenderSelectionViewModel(nickname: nickname))
        self.agreements = agreements
        self.embeddedInFlow = embeddedInFlow
        self.onSkip = onSkip
        self.onNext = onNext
    }

    // VM 선택값 → 서버 코드
    private var selectedGenderCode: GenderCode? {
        switch vm.selected {
        case .some(.male):   return .M
        case .some(.female): return .W
        default:             return nil
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if !embeddedInFlow {
                ProgressIndicator(currentStep: 2, totalSteps: 5)
            }

            (Text("1").foregroundStyle(Color.black100)+Text("/2").foregroundStyle(Color.gray900))
                .fontName(.bodyMedium16)
                .padding(.top, 17)
                .padding(.horizontal, 32)
                .frame(maxWidth: .infinity, alignment: .trailing)

            VStack(alignment: .leading, spacing: 3) {
                Text("먼저 성별을 선택해주세요")
                    .fontName(.titleBold24)
                    .foregroundStyle(Color.black100)
                Text("더 나은 추천을 위해 필요해요")
                    .fontName(.titleMedium24)
                    .foregroundStyle(Color.black100)
            }
            .padding(.horizontal, 32)

            HStack(spacing: 9) {
                ForEach(GenderOption.allCases) { option in
                    Button {
                        vm.select(option)
                    } label: {
                        Text(option.label)
                            .fontName(.captionMedium14)
                            .foregroundStyle(Color.black100)
                            .padding(.vertical, 17)
                            .padding(.leading, 19)
                            .padding(.trailing, 21)
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(
                                        vm.selected == option
                                        ? Color.black100
                                        : Color.gray800,
                                        lineWidth: 1.5
                                    )
                            )
                    }
                }
            }
            .padding(.horizontal, 30)
            .padding(.top, 55)

            Spacer()

            VStack(spacing: 20) {
                Button {
                    vm.skip()
                    if vm.didTapSkip {
                        onSkip?() // 통합 플로우 콜백
                    }
                } label: {
                    Text("건너뛰기")
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
                        onNext?(selectedGenderCode) // 통합 플로우 콜백
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
                .disabled(vm.selected == nil)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 22)
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            print("DEBUG Gender →", agreements.map { "\($0.termsType)=\($0.isAgreed)" })
        }
    }
}
