//
//  StartViewModel.swift
//  weady
//
//  Created by 김영택 on 8/6/25.
//

import SwiftUI

@MainActor
final class StartViewModel: ObservableObject {
    // 입력값
    let nickname: String
    let gender: GenderCode?
    let styleIds: [Int64]?
    let agreements: [OnboardingAgreement]?

    // 상태
    @Published var isSubmitting = false
    @Published var navigateHome = false
    @Published var lastErrorMessage: String?

    private let service: OnboardingService
    private var didRouteOnce = false 

    init(
        nickname: String,
        gender: GenderCode? = nil,
        styleIds: [Int64]? = nil,
        agreements: [OnboardingAgreement]? = nil,
        service: OnboardingService = OnboardingService()
    ) {
        self.nickname = nickname
        self.gender = gender
        self.styleIds = styleIds
        self.agreements = agreements
        self.service = service
    }

    func startTapped() {
        guard !isSubmitting, !didRouteOnce else { return }
        isSubmitting = true
        Task { await postAndNavigate() }
    }

    // 버튼 시점에만 POST
    private func postAndNavigate() async {
        defer { isSubmitting = false }

        // 1) 약관 검증 (필수 3개)
        guard let agreements, requiredAgreed(agreements) else {
            self.lastErrorMessage = "필수 약관 동의 누락(만 14세 · 서비스 · 개인정보)"
            return
        }

        // 2) gender 없으면 NONE으로 대체하여 POST
        let genderToSend: GenderCode = gender ?? .NONE
        let styleIdsToSend: [Int64] = styleIds ?? []

        let body = OnboardingRequestDTO(
            name: nickname,
            gender: genderToSend,
            styleIds: styleIdsToSend,
            agreements: agreements
        )

        do {
            try await service.submit(body: body)
            routeHomeOnce()
        } catch let api as APIErrorResponse {
            // ✅ 닉네임 중복(400)만 예외적으로 통과
            if api.code == 400, api.message.contains("이미 사용 중") {
                routeHomeOnce()
                return
            }
            self.lastErrorMessage = api.message
        } catch {
            self.lastErrorMessage = "요청 처리 실패(네트워크/디코딩 등)"
        }
    }

    private func routeHomeOnce() {
        guard !didRouteOnce else { return }
        didRouteOnce = true
        navigateHome = true
    }

    private func requiredAgreed(_ a: [OnboardingAgreement]) -> Bool {
        let required: Set<TermsType> = [.AGE, .SERVICE, .PRIVACY]
        let dict = Dictionary(uniqueKeysWithValues: a.map { ($0.termsType, $0.isAgreed) })
        return required.allSatisfy { dict[$0] == true }
    }
}
