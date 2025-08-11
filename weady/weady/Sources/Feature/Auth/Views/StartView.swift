//
//  StartView.swift
//  weady
//
//  Created by 김영택 on 8/6/25.
//

import SwiftUI

struct StartView: View {
    @StateObject private var vm: StartViewModel

    init(nickname: String) {
        _vm = StateObject(wrappedValue: StartViewModel(nickname: nickname))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 1) 프로그레스 인디케이터 (5번째 스텝)
            ProgressIndicator(currentStep: 4, totalSteps: 5)

            // 2) 타이틀: 언더라인된 닉네임 + 나머지 텍스트
            VStack(alignment: .leading, spacing: 4) {
                Text("취향 입력이 완료되었어요 !")
                    .fontName(.titleBold24)
                    .foregroundStyle(Color.black100)
                
                Spacer().frame(height: 25)
                
                Text("앞으로 웨디가")
                    .fontName(.titleMedium24)
                    .foregroundStyle(Color.black100)
                
                HStack(spacing: 0) {
                    Text("\(vm.nickname)님")
                        .fontName(.titleBold24)
                        .foregroundStyle(Color.black100)
                    Text("의 취향에 맞는 하루를")
                        .fontName(.titleMedium24)
                        .foregroundStyle(Color.black100)
                }
                
                Text("추천해드릴게요.")
                    .fontName(.titleMedium24)
                    .foregroundStyle(Color.black100)
            }
            .padding(.horizontal, 32)
            .padding(.top, 39)

            Spacer().frame(height: 78)

            // 3) 중앙 일러스트 버튼
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 212, height: 212)
                Text("웨디 일러스트")
                    .font(.system(size: 16))
                    .foregroundColor(.black)
            }
            .frame(maxWidth: .infinity)

            Spacer()

            // 4) 다음 버튼

            Button(action: vm.next) {
                Text("웨디 시작하기")
                    .fontName(.bodyMedium16)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 11)
                    .background(Color.black100)
                    .foregroundStyle(Color.white100)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 22)
        }
        //Next
        .fullScreenCover(isPresented: $vm.didTapNext) {
            // 일단 웨디시작하기 버튼 눌렀을 때 홈 화면 넘어가도록 임의로 설정 
            BaseTabContainerView()
        }
    }
}

#Preview {
    StartView(nickname: "테스트")
}
