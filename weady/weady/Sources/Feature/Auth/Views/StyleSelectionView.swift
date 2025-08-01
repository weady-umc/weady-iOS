//
//  StyleSelectionView.swift
//  weady
//
//  Created by 김영택 on 8/1/25.
//

import SwiftUI

struct StyleSelectionView: View {
    @StateObject private var vm: StyleSelectionViewModel

    init(nickname: String) {
        _vm = StateObject(wrappedValue: StyleSelectionViewModel(nickname: nickname))
    }

    // 3열 그리드 레이아웃
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // 상단 인디케이터 
            ProgressIndicator(currentStep: 3, totalSteps: 5)
            
            (Text("1").foregroundStyle(Color.gray900)+Text("/2").foregroundStyle(Color.black100))
                .fontName(.bodyMedium16)
                .padding(.top, 17)
                .padding(.horizontal, 32)
                .frame(maxWidth: .infinity, alignment: .trailing)

            // 타이틀
            VStack(alignment: .leading){
                HStack(alignment: .top, spacing: 0) {
                    Text(vm.nickname)
                        .font(.system(size: 24, weight: .semibold))
                        .underline(true, color: .black)
                    Text("님은 어떤 스타일의")
                        .font(.system(size: 24, weight: .semibold))
                }
                Text("옷차림을 좋아하시나요?")
                    .font(.system(size: 24, weight: .semibold))
            }
            .padding(.horizontal, 32)

            // 스타일 옵션 그리드
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(StyleOption.allCases) { option in
                    Button {
                        vm.toggle(option)
                    } label: {
                        Text(option.rawValue)
                            .font(.system(size: 14))
                            .foregroundColor(vm.selected.contains(option)
                                             ? .black
                                             : Color.gray.opacity(0.6))
                            .frame(height: 44)
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(
                                        vm.selected.contains(option)
                                            ? Color.black
                                            : Color.gray.opacity(0.3),
                                        lineWidth: 1
                                    )
                            )
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 32)

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
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 22)
        }
        // 다음 단계(예: AgeSelectionView)로 전환
        .fullScreenCover(isPresented: $vm.didTapNext) {
            EmptyView()
        }
    }
}

// Preview
struct StyleSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        StyleSelectionView(nickname: "영택")
    }
}
