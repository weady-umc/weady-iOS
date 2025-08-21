//
//  StyleSelectionView.swift
//  weady
//
//  Created by 김영택 on 8/6/25.
//

import SwiftUI

struct StyleSelectionView: View {
    @StateObject private var vm: StyleSelectionViewModel

    private let gender: GenderCode?
    private let agreements: [OnboardingAgreement]

    // 통합 플로우 모드
    var embeddedInFlow: Bool = false
    var onSkip: (() -> Void)? = nil
    var onNext: (([Int64]) -> Void)? = nil

    init(
        nickname: String,
        gender: GenderCode? = nil,
        agreements: [OnboardingAgreement],
        embeddedInFlow: Bool = false,
        onSkip: (() -> Void)? = nil,
        onNext: (([Int64]) -> Void)? = nil,
        service: TagServiceProtocol = TagService()
    ) {
        self.gender = gender
        self.agreements = agreements
        self.embeddedInFlow = embeddedInFlow
        self.onSkip = onSkip
        self.onNext = onNext
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
    }

    @ViewBuilder
    private func headerView() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            if !embeddedInFlow {
                ProgressIndicator(currentStep: 3, totalSteps: 5)
            }

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
            Text("에러: \(err)").foregroundColor(.red)
            Spacer()
        } else {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(vm.categories, id: \.id) { cat in
                    CategoryButton(
                        name: cat.name,
                        isSelected: vm.selectedIds.contains(cat.id)
                    ) { vm.toggle(cat) }
                }
            }
            .padding(.horizontal, 30)
        }
    }

    @ViewBuilder
    private func footerView() -> some View {
        VStack(spacing: 20) {
            Button {
                vm.skip()
                if vm.didTapSkip {
                    onSkip?() // 통합 플로우 콜백
                }
            } label: {
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

            Button {
                vm.next()
                if vm.didTapNext {
                    let ids: [Int64] = Array(vm.selectedIds).map { Int64($0) }.sorted()
                    onNext?(ids) // 통합 플로우 콜백
                }
            } label: {
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
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(
                            isSelected ? Color.black100 : Color.gray700,
                            lineWidth: isSelected ? 3 : 2
                        )
                )
                .cornerRadius(4)
        }
    }
}
