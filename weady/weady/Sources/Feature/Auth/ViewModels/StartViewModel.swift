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
            // ✅ 서비스가 비정상(비-2xx)에서 throw 한다는 가정
            _ = try await service.submit(body: body)
            // ✅ 성공(2xx)일 때만 이동 신호
            navigateHome = true
        } catch let api as APIErrorResponse {
            // ✅ 닉네임 중복(400)만 예외적으로 통과
            if api.code == 400, api.message.contains("이미 사용 중") {
                navigateHome = true
                return
            }
            
            // ❌ 500 포함 그 외 모든 에러: 이동 금지 + 얼럿
            alert = .init(title: "온보딩 실패", message: api.message)
            
        } catch {
            // ❌ 네트워크/디코딩 등 기타 예외: 이동 금지 + 얼럿
            alert = .init(
                title: "온보딩 실패",
                message: "요청 처리에 실패했습니다. 네트워크 상태를 확인해 주세요."
            )
        }
    }

    private func requiredAgreed(_ a: [OnboardingAgreement]) -> Bool {
        let required: Set<TermsType> = [.AGE, .SERVICE, .PRIVACY]
        let dict = Dictionary(uniqueKeysWithValues: a.map { ($0.termsType, $0.isAgreed) })
        return required.allSatisfy { dict[$0] == true }
    }
}
