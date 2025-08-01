//
//  GenderSelectionView.swift
//  weady
//
//  Created by 김영택 on 8/1/25.
//

import SwiftUI

struct GenderSelectionView: View {
    @StateObject private var vm: GenderSelectionViewModel
    
    init(nickname: String) {
        _vm = StateObject(wrappedValue: GenderSelectionViewModel(nickname: nickname))
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
            .padding(.top, 17)
            
            // 옵션 버튼
            HStack(spacing: 9) {
                ForEach(GenderOption.allCases) { option in
                    Button {
                        vm.select(option)
                    } label: {
                        Text(option.label)
                            .fontName(.captionMedium14)
                            .foregroundStyle(Color.black100)
                            .frame(height: 50)
                            .frame(width: 94)
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(
                                        vm.selected == option
                                        ? Color.black100
                                        : Color.gray800,
                                        lineWidth: 2
                                    )
                            )
                    }
                }
            }
            .padding(.horizontal, 30)
            .padding(.top, 55)
            
            Spacer().frame(height: 363)
            
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
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 22)
        }
        //다음 뷰 연결
        .fullScreenCover(isPresented: $vm.didTapSkip) {
            // 건너뛸 때 이동할 뷰
            EmptyView()
        }
        .fullScreenCover(isPresented: $vm.didTapNext) {
            // 다음에 이동할 뷰
            StyleSelectionView(nickname: vm.nickname)
        }
    }
}


#Preview {
    GenderSelectionView(nickname: "테스트")
}
