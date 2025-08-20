////
////  OnboardingFlowHost.swift
////  weady
////
////  Created by 엄민서 on 8/20/25.
////
//
//import SwiftUI
//
//struct OnboardingFlowHost: View {
//    @StateObject private var onboardingRouter = OnboardingRouter()
//    @StateObject private var onboardingState = OnboardingState()
//
//    var body: some View {
//        NavigationStack(path: $onboardingRouter.path) {
//            TermsAgreementView()
//                .environment(onboardingRouter)
//                .environmentObject(onboardingState)
//                .toolbar(.hidden, for: .navigationBar)
//                .navigationDestination(for: OnboardingRoute.self) { route in
//                    switch route {
//                    case .terms:
//                        TermsAgreementView()
//                            .environment(onboardingRouter)
//                            .environmentObject(onboardingState)
//                            .toolbar(.hidden, for: .navigationBar)
//
//                    case .nickname:
//                        NicknameInputView()
//                            .environment(onboardingRouter)
//                            .environmentObject(onboardingState)
//                            .toolbar(.hidden, for: .navigationBar)
//
//                    case .preference:
//                        PreferenceInputView()
//                            .environment(onboardingRouter)
//                            .environmentObject(onboardingState)
//                            .toolbar(.hidden, for: .navigationBar)
//
//                    case .gender:
//                        GenderSelectionView()
//                            .environment(onboardingRouter)
//                            .environmentObject(onboardingState)
//                            .toolbar(.hidden, for: .navigationBar)
//
//                    case .style:
//                        StyleSelectionView()
//                            .environment(onboardingRouter)
//                            .environmentObject(onboardingState)
//                            .toolbar(.hidden, for: .navigationBar)
//
//                    case .start:
//                        StartView()
//                            .environment(onboardingRouter)
//                            .environmentObject(onboardingState)
//                            .toolbar(.hidden, for: .navigationBar)
//                    }
//                }
//        }
//        .environment(onboardingRouter)
//        .environmentObject(onboardingState)
//        .onAppear {
//            // 최초 진입 지점
//            if onboardingRouter.path.isEmpty {
//                onboardingRouter.push(.terms)
//            }
//        }
//    }
//}
