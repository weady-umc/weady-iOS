//
//  OnboardingFlowView.swift
//  weady
//
//  Created by 엄민서 on 8/21/25.
//

import SwiftUI

private enum Step {
    case terms
    case nickname
    case preference
    case gender
    case style
    case start
}

struct OnboardingFlowView: View {
    @State private var step: Step = .terms

    @State private var agreements: [OnboardingAgreement] = []
    @State private var nickname: String = ""
    @State private var gender: GenderCode? = nil
    @State private var styleIds: [Int64] = []
    @AppStorage("nickname") private var storedNickname: String = ""

    var onFinished: (() -> Void)? = nil

    private let visibleTotalSteps = 5
    private var visibleIndex: Int? {
        switch step {
        case .terms: return nil
        case .nickname: return 0
        case .preference: return 1
        case .gender: return 2
        case .style: return 3
        case .start: return 4
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let idx = visibleIndex {
                ProgressIndicator(currentStep: idx, totalSteps: visibleTotalSteps)
            }

            ZStack {
                content
                    .id(step)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            }
            .animation(.easeInOut, value: step)
        }
        .navigationBarBackButtonHidden(true)
    }

    @ViewBuilder
    private var content: some View {
        switch step {
        case .terms:
            TermsAgreementView { payload in
                agreements = payload
                step = .nickname
            }

        case .nickname:
            NicknameInputView(
                agreements: agreements,
                embeddedInFlow: true
            ) { name in
                nickname = name
                step = .preference
            }

        case .preference:
            PreferenceInputView(
                nickname: nickname,
                agreements: agreements,
                embeddedInFlow: true,
                onSkip: {
                    gender = nil
                    styleIds = []
                    step = .start
                },
                onNext: {
                    step = .gender
                }
            )

        case .gender:
            GenderSelectionView(
                nickname: nickname,
                agreements: agreements,
                embeddedInFlow: true,
                onSkip: {
                    gender = .NONE
                    styleIds = []
                    step = .style
                },
                onNext: { g in
                    gender = g
                    step = .style
                }
            )

        case .style:
            StyleSelectionView(
                nickname: nickname,
                gender: gender,
                agreements: agreements,
                embeddedInFlow: true,
                onSkip: {
                    styleIds = []
                    step = .start
                },
                onNext: { ids in
                    styleIds = ids
                    step = .start
                }
            )

        case .start:
            StartView(
                nickname: nickname,
                gender: gender,
                styleIds: styleIds,
                agreements: agreements
            ) {
                onFinished?()
            }
        }
    }
}
