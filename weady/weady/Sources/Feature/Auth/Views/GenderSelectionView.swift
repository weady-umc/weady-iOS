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
    
    init(nickname: String, agreements: [OnboardingAgreement]) {
        _vm = StateObject(wrappedValue: GenderSelectionViewModel(nickname: nickname))
        self.agreements = agreements
    }
    //보조 프로퍼티: VM의 선택값을 서버 코드로 변환
    private var selectedGenderCode: GenderCode? {
        switch vm.selected {
        case .some(.male):   return .M
        case .some(.female): return .W
        default:             return nil
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            //상단 인디케이터 + 페이지 표시
            ProgressIndicator(currentStep: 2, totalSteps: 5)
            
            (Text("1").foregroundStyle(Color.black100)+Text("/2").foregroundStyle(Color.gray900))
                .fontName(.bodyMedium16)
                .padding(.top, 17)
                .padding(.horizontal, 32)
                .frame(maxWidth: .infinity, alignment: .trailing)
            
            // 제목 / 부제
            VStack(alignment: .leading, spacing: 3) {
                Text("먼저 성별을 선택해주세요")
                    .fontName(.titleBold24)
                    .foregroundStyle(Color.black100)
                Text("더 나은 추천을 위해 필요해요")
                    .fontName(.titleMedium24)
                    .foregroundStyle(Color.black100)
            }
            .padding(.horizontal, 32)
            
            // 옵션 버튼
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
            
            // 하단 버튼
            VStack(spacing: 20) {
                Button(action: vm.skip) {
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
                
                Button(action: vm.next) {
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
        // 스킵 → StartView (성별 없음, agreements 전달)
        .fullScreenCover(isPresented: $vm.didTapSkip) {
            StartView(
                nickname: vm.nickname,
                gender: .NONE,          // 성별 건너뛰기 NONE 사용
                styleIds: [],           // 건너뛰기이므로 빈 배열
                agreements: agreements  // 약관 그대로 릴레이
            )
        }
        // 다음 → StyleSelection (선택 성별/agreements 전달)
        .fullScreenCover(isPresented: $vm.didTapNext) {
            StyleSelectionView(
                nickname: vm.nickname,
                gender: selectedGenderCode,
                agreements: agreements
            )
        }
    }
}


/*#Preview {
 GenderSelectionView(nickname: "테스트")
 }
 */

