//
//  StyleSelectionView.swift
//  weady
//
//  Created by 김영택 on 8/6/25.
//

import SwiftUI

struct StyleSelectionView: View {
    // 외부 주입용 ViewModel
    @StateObject private var vm: StyleSelectionViewModel
    @State private var showNext = false

    private let gender: GenderCode?
    private let agreements: [OnboardingAgreement]

    init(
        nickname: String,
        gender: GenderCode? = nil,
        agreements: [OnboardingAgreement],
        service: TagServiceProtocol = TagService()
    ) {
        self.gender = gender
        self.agreements = agreements
        _vm = StateObject(wrappedValue: StyleSelectionViewModel(nickname: nickname, service: service))
    }
    
    private let columns: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 15), count: 3)


    var body: some View {
        VStack(alignment: .leading) {
            headerView()
            Spacer().frame(height: 55)
            contentView()
            Spacer()
            footerView()
        }
        .onAppear {
            print("DEBUG Style →", agreements.map { "\($0.termsType)=\($0.isAgreed)" })
            vm.loadCategories()
        }
        // 다음 → StartView (스타일 포함)
        .fullScreenCover(isPresented: $vm.didTapNext) {
            let styleIds64: [Int64] = Array(vm.selectedIds).map { Int64($0) }.sorted()
            StartView.onboarding(
                nickname: vm.nickname,
                gender: gender,
                styleIds: styleIds64,
                agreements: agreements
            )
        }
        // 스킵 → StartView (스타일 없음)
        .fullScreenCover(isPresented: $vm.didTapSkip) {
            let styleIds64: [Int64] = []   // 스킵이면 빈 배열
            StartView.onboarding(
                nickname: vm.nickname,
                gender: gender,
                styleIds: styleIds64,
                agreements: agreements
            )
        }
    }
    

    @ViewBuilder
    private func headerView() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            //상단 인디케이터 + 페이지 표시
            ProgressIndicator(currentStep: 3, totalSteps: 5)
            
            (Text("2").foregroundStyle(Color.black100)+Text("/2").foregroundStyle(Color.gray900))
                .fontName(.bodyMedium16)
                .padding(.top, 17)
                .padding(.horizontal, 32)
                .frame(maxWidth: .infinity, alignment: .trailing)
            
            Text("\(vm.nickname)님은 어떤 스타일의 옷차림을 좋아하시나요?")
                .fontName(.titleBold24)
                .foregroundStyle(Color.black100)
                .padding(.horizontal, 32)
                .padding(.top, 17)
        }
    }

    @ViewBuilder
    private func contentView() -> some View {
        if vm.isLoading {
            Spacer()
            ProgressView("불러오는 중…")
            Spacer()

        } else if let err = vm.errorMessage {
            Spacer()
            Text("에러: \(err)")
                .foregroundColor(.red)
            Spacer()

        } else {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(vm.categories, id: \.id) { cat in
                    CategoryButton(
                        name: cat.name,
                        isSelected: vm.selectedIds.contains(cat.id)
                    ) {
                        vm.toggle(cat)
                    }
                }
            }
            .padding(.horizontal, 30)
        }
    }

    @ViewBuilder
    private func footerView() -> some View {
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
}

struct CategoryButton: View {
    let name: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(name)
                .fontName(.captionRegular14)
                .foregroundStyle(.black)
                .frame(maxWidth: 314, minHeight: 40)
                .background(isSelected ? Color.white200 : Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(
                            isSelected ? Color.black100 : Color.gray700,
                            lineWidth: isSelected ? 3 : 2
                        )
                )
                .cornerRadius(8)
        }
    }
}
/*
struct StyleSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        StyleSelectionView(nickname: "테스트")
    }
}

*/
