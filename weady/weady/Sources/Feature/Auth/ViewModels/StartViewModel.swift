//
//  StartViewModel.swift
//  weady
//
//  Created by 김영택 on 8/6/25.
//

import SwiftUI

@MainActor
final class StartViewModel: ObservableObject {
    enum Route: Equatable { case home, terms }
    @Published var route: Route?
    
    // MARK: Inputs
    let nickname: String
    let gender: GenderCode?
    let styleIds: [Int64]?
    let agreements: [OnboardingAgreement]?

    // MARK: UI State
    @Published var didTapNext: Bool = false
    @Published var isSubmitting = false
    @Published var alertMessage: String?

    // MARK: Service
    private let service: OnboardingService
    
    private func hasAllRequiredAgreements(_ arr: [OnboardingAgreement]) -> Bool {
        let required: Set<TermsType> = [.AGE, .SERVICE, .PRIVACY]
        return required.allSatisfy { t in
            arr.contains { $0.termsType == t && $0.isAgreed }
        }
    }

    init(nickname: String,
         gender: GenderCode? = nil,
         styleIds: [Int64]? = nil,
         agreements: [OnboardingAgreement]? = nil,
         service: OnboardingService = OnboardingService()) {
        self.nickname   = nickname
        self.gender     = gender
        self.styleIds   = styleIds
        self.agreements = agreements
        self.service    = service
    }

    func next() {
        guard !isSubmitting else { return }
        Task { await handleStart() }
    }

    func handleStart() async {
        guard !isSubmitting else { return }
        
        // 닉네임 길이 사전 검증(옵션)
        guard (2...15).contains(nickname.count) else {
            alertMessage = "닉네임은 2~15자여야 합니다."
            return
        }
        // 필수값 없으면 POST 생략하고 기존 흐름 유지
        guard let gender, let agreements else {
            route = .home
            return
        }
        // 서버 보내기 전에 필수 동의 보장
        guard hasAllRequiredAgreements(agreements) else {
            alertMessage = "필수 약관 동의가 누락되었습니다. (만 14세 · 서비스 · 개인정보)"
            return
        }
        
        isSubmitting = true
        defer { isSubmitting = false }
        
        let body = OnboardingRequestDTO(
            name: nickname,
            gender: gender,
            styleIds: styleIds ?? [],
            agreements: agreements
        )
        
        do {
            let res = try await service.submit(body: body)
            let tokens = res.data
    
            AuthManager.shared.saveTokens(
                   accessToken: tokens.accessToken,
                   refreshToken: tokens.refreshToken
               )
            
            route = tokens.isNewUser ? .terms : .home
            print("VM set route =", String(describing: route))
            
        } catch let api as APIErrorResponse {
            // 예: "이미 사용 중인 닉네임입니다."
            alertMessage = api.message
        } catch {
            alertMessage = "요청 처리에 실패했습니다. 잠시 후 다시 시도해 주세요."
        }
    }
}
