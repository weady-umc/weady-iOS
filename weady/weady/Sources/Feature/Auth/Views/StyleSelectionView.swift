//
//  StyleSelectionView.swift
//  weady
//
//  Created by 김영택 on 8/1/25.
//

import SwiftUI

struct StyleSelectionView: View {
    @StateObject private var vm = StyleSelectionViewModel()

    // 1) 3열 그리드 정의
    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: 12),
        count: 3
    )

    var body: some View {
        VStack(spacing: 16) {
            // 상단 진행바 / 질문 텍스트 생략

            Group {
                if vm.isLoading {
                    Spacer()
                    ProgressView("불러오는 중…")
                    Spacer()
                } else if let error = vm.errorMessage {
                    Spacer()
                    Text("에러: \(error)")
                        .foregroundColor(.red)
                    Spacer()
                } else {
                    ScrollView {
                      LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(vm.categories, id: \.id) { cat in
                          CategoryButton(
                            name: cat.name,
                            isSelected: vm.selectedIds.contains(cat.id)
                          ) {
                            vm.toggle(cat)
                          }
                        }
                      }
                      .padding(.horizontal)
                    }
                }
            }
            .animation(.easeInOut, value: vm.categories)

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
                        .background(vm.canProceed ? Color.black100 : Color.gray200)
                        .foregroundStyle(Color.white100)
                        .cornerRadius(10)
                }
                .disabled(!vm.canProceed)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 22)
        }
        // 다음 화면 전환
        .fullScreenCover(isPresented: $vm.didTapNext) {
            EmptyView()
        }
    }
}

struct CategoryButton: View {
    let name: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(name)
                .font(.subheadline)
                .foregroundColor(isSelected ? .white : .black)
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(isSelected ? Color.black : Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.black, lineWidth: 1)
                )
                .cornerRadius(8)
        }
    }
}

struct StyleSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        StyleSelectionView()
    }
}
