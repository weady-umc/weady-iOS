//
//  PreferenceInputView.swift
//  weady
//
//  Created by 김영택 on 8/1/25.
//

import SwiftUI

struct PreferenceInputView: View {
    @StateObject private var vm: PreferenceInputViewModel

    private let agreements: [OnboardingAgreement]?

    init(nickname: String, agreements: [OnboardingAgreement]? = nil) {
        _vm = StateObject(wrappedValue: PreferenceInputViewModel(nickname: nickname))
        self.agreements = agreements
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 1) 프로그레스 인디케이터 (2번째 스텝)
            ProgressIndicator(currentStep: 1, totalSteps: 5)

            // 2) 타이틀: 언더라인된 닉네임 + 나머지 텍스트
            VStack(alignment: .leading, spacing: 18) {
                HStack(spacing: 0) {
                    Text(vm.nickname)
                        .fontName(.titleBold24)
                        .foregroundStyle(Color.black100)
                    Text("님의 취향을 알고싶어요!")
                        .fontName(.titleBold24)
                        .foregroundStyle(Color.black100)
                }
                Text("내 정보를 입력하면\n웨디가 조금 더 맞춤형 추천을 드릴 수 있어요 :)")
                    .fontName(.metaMedium12)
                    .foregroundStyle(Color.gray900)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false,
                               vertical: true)
            }
            .padding(.horizontal, 32)
            .padding(.top, 39)

            Spacer()

            // 3) 중앙 일러스트 버튼
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 200, height: 200)
                Text("웨디 일러스트")
                    .font(.system(size: 16))
                    .foregroundColor(.black)
            }
            .frame(maxWidth: .infinity)

            Spacer().frame(height: 146)

            // 4) 하단 버튼들
            VStack(spacing: 20) {
                Button(action: vm.skip) {
                    Text("취향입력 건너뛰기")
                        .fontName(.bodyMedium16)
                        .foregroundStyle(Color.gray800)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 11)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray800, lineWidth: 1)
                        )
                }

                Button(action: vm.next) {
                    Text("다음")
                        .fontName(.bodyMedium16)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 11)
                        .background(Color.black100)
                        .foregroundStyle(Color.white100)
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 22)
        }
        // 스킵 → StartView 로 이동할 때 agreements 전달
        .fullScreenCover(isPresented: $vm.didTapSkip) {
            StartView(nickname: vm.nickname, agreements: agreements) // 성별/스타일은 아직 없음
        }
        // 다음 → GenderSelection 로 이동할 때 agreements 전달
        .fullScreenCover(isPresented: $vm.didTapNext) {
            GenderSelectionView(nickname: vm.nickname, agreements: agreements)
        }
    }
}

#Preview {
    PreferenceInputView(nickname: "테스트")
}
