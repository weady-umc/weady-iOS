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
    @Published var alert: AlertState?

    private let service: OnboardingService

    struct AlertState: Identifiable {
        let id = UUID()
        let title: String
        let message: String
    }

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
        Task { await postAndNavigate() }
    }

    // 버튼 시점에만 POST
    private func postAndNavigate() async {
        // 1) 약관 검증 (필수 3개)
        guard let agreements, requiredAgreed(agreements) else {
            alert = .init(
                title: "약관 확인",
                message: "필수 약관 동의가 누락되었습니다. (만 14세 · 서비스 · 개인정보)"
            )
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

        isSubmitting = true
        defer { isSubmitting = false }

        do {
            let res = try await service.submit(body: body)
            // 성공이면 그대로 홈 이동
            navigateHome = true
        } catch let api as APIErrorResponse {
            // 서버가 표준 에러 포맷을 준 경우
            if api.code == 400, api.message.contains("이미 사용 중") {
                // 닉네임 중복 = 보통 이미 온보딩 사용자 → 막지 말고 홈으로 보냄
                navigateHome = true
                return
            }
            if api.code >= 500 {
                // 서버 내부 오류도 사용자 진행 막지 않음 (기존 유저일 가능성)
                navigateHome = true
                return
            }
            // 그 외 에러만 경고
            alert = .init(title: "실패", message: api.message)
        } catch {
            // 네트워크/디코딩 등 기타 예외
            // 필요에 따라 홈으로 우회하거나, 안내만 띄울지 선택
            alert = .init(title: "실패", message: "요청 처리에 실패했습니다. 네트워크 상태를 확인해 주세요.")
        }
    }

    private func requiredAgreed(_ a: [OnboardingAgreement]) -> Bool {
        let required: Set<TermsType> = [.AGE, .SERVICE, .PRIVACY]
        let dict = Dictionary(uniqueKeysWithValues: a.map { ($0.termsType, $0.isAgreed) })
        return required.allSatisfy { dict[$0] == true }
    }
}
