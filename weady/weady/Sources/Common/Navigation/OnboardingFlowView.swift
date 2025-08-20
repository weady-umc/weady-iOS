////
////  OnboardingFlowView.swift
////  weady
////
////  Created by 엄민서 on 8/20/25.
////
////

//
//import SwiftUI
//
///// 온보딩 단계 라우트
//private enum OnboardingRoute: Hashable {
//    case terms
//    case nickname(agreements: [OnboardingAgreement])
//    case preference(nickname: String, agreements: [OnboardingAgreement])
//    case gender(nickname: String, agreements: [OnboardingAgreement])
//    case style(nickname: String, gender: GenderCode?, agreements: [OnboardingAgreement])
//    case start(nickname: String, gender: GenderCode?, styleIds: [Int64]?, agreements: [OnboardingAgreement])
//}
//
///// 온보딩 전체 플로우 컨테이너 (NavigationStack 기반)
//struct OnboardingFlowView: View {
//    @State private var path: [OnboardingRoute] = [.terms]
//
//    /// 온보딩이 끝났을 때(탭 화면으로) 전환 콜백
//    var onFinished: (() -> Void)?
//
//    var body: some View {
//        NavigationStack(path: $path) {
//            // 첫 화면
//            TermsAgreementView { agreements in
//                path.append(.nickname(agreements: agreements))
//            }
//            .navigationDestination(for: OnboardingRoute.self) { route in
//                switch route {
//                case .terms:
//                    TermsAgreementView { agreements in
//                        path.append(.nickname(agreements: agreements))
//                    }
//
//                case let .nickname(agreements):
//                    NicknameInputView(agreements: agreements, embeddedInFlow: true) { nickname in
//                        path.append(.preference(nickname: nickname, agreements: agreements))
//                    }
//
//                case let .preference(nickname, agreements):
//                    PreferenceInputView(
//                        nickname: nickname,
//                        agreements: agreements,
//                        embeddedInFlow: true,
//                        onSkip: {
//                            // 취향 입력 스킵 → 성별/스타일 모두 없이 Start
//                            path.append(.start(nickname: nickname, gender: nil, styleIds: [], agreements: agreements))
//                        },
//                        onNext: {
//                            path.append(.gender(nickname: nickname, agreements: agreements))
//                        }
//                    )
//
//                case let .gender(nickname, agreements):
//                    GenderSelectionView(
//                        nickname: nickname,
//                        agreements: agreements,
//                        embeddedInFlow: true
//                    ) { gender in
//                        // 선택 안함(nil) 포함해서 전달
//                        path.append(.style(nickname: nickname, gender: gender, agreements: agreements))
//                    }
//
//                case let .style(nickname, gender, agreements):
//                    StyleSelectionView(
//                        nickname: nickname,
//                        gender: gender,
//                        agreements: agreements,
//                        embeddedInFlow: true,
//                        onSkip: {
//                            path.append(.start(nickname: nickname, gender: gender, styleIds: [], agreements: agreements))
//                        },
//                        onNext: { styleIds64 in
//                            path.append(.start(nickname: nickname, gender: gender, styleIds: styleIds64, agreements: agreements))
//                        }
//                    )
//
//                case let .start(nickname, gender, styleIds, agreements):
//                    StartView(
//                        nickname: nickname,
//                        gender: gender,
//                        styleIds: styleIds,
//                        agreements: agreements
//                    ) {
//                        // 온보딩 종료: 컨테이너 밖에서 탭 화면으로 전환 처리
//                        onFinished?()
//                    }
//                }
//            }
//        }
//    }
//}
