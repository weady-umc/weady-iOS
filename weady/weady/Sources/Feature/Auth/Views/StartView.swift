//
//  StartView.swift
//  weady
//
//  Created by 김영택 on 8/6/25.
//

import SwiftUI

struct StartView: View {
    @StateObject private var vm: StartViewModel
    @State private var showHome = false
    @State private var showTerms = false
    @Environment(NavigationRouter.self) private var router
    @Environment(\.dismiss) private var dismiss
    
    init(nickname: String) {
        _vm = StateObject(wrappedValue: StartViewModel(nickname: nickname))
    }
    
    // 신규 init (옵셔널 파라미터)
    init(nickname: String,
         gender: GenderCode? = nil,
         styleIds: [Int64]? = nil,
         agreements: [OnboardingAgreement]? = nil) {
        _vm = StateObject(wrappedValue: StartViewModel(
            nickname: nickname,
            gender: gender,
            styleIds: styleIds,
            agreements: agreements
        ))
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
            
            Button{
                print("VM.route =", String(describing: vm.route))
                 print("Router path count(before) =", router.path.count)
                Task { await vm.handleStart() }
            } label: {
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
        
        // 전역 라우터로 라우팅
        .onReceive(vm.$route.removeDuplicates()) { route in
            print("Route recv:", String(describing: route),
                  "| path count(before) =", router.path.count)

            switch route {
            case .home?:
                router.reset()
                router.push(.basetab)
                dismiss()
                print("→ pushed .basetab | path count(after) =", router.path.count)
             
            case .terms?:
                router.reset()
                router.push(.onboarding)
                dismiss()
                print("→ pushed .onboarding | path count(after) =", router.path.count)
        
            case nil:
                break
            }
        }
        // 서버 에러 메시지 얼럿
        .alert("알림",
               isPresented: Binding(
                get: { vm.alertMessage != nil },
                set: { if !$0 { vm.alertMessage = nil } }
               ),
               actions: { Button("확인") { vm.alertMessage = nil } },
               message: { Text(vm.alertMessage ?? "") }
        )
    }
}

#Preview {
    StartView(nickname: "테스트").environment(NavigationRouter())
}


