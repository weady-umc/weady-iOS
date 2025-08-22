//
//  SettingView.swift
//  weady
//
//  Created by 김영택 on 7/17/25.
//

import SwiftUI

struct SettingView: View {
    @StateObject private var viewModel = SettingViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 30) {
                ForEach(viewModel.sections) { section in
                    SettingSectionView(
                        section: section,
                        onLogout: { viewModel.requestLogout() }
                    )
                }
            }
            .padding(.bottom, 200)
            .padding(.top, 100)
            .navigationTitle("설정 및 개인정보")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundStyle(Color.black100)
                    }
                }
            }
            
            if viewModel.isLoggingOut {
                ProgressView("로그아웃 중...")
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                    .background(Color.black.opacity(0.08))
                    .cornerRadius(12)
            }
        }
        .onChange(of: viewModel.didLogout) { _, newValue in
            guard newValue else { return }
            dismiss()
        }
        .alert("알림", isPresented: .constant(viewModel.logoutErrorMessage != nil)) {
            Button("확인", role: .cancel) { viewModel.logoutErrorMessage = nil }
        } message: {
            Text(viewModel.logoutErrorMessage ?? "")
        }
    }
}

struct SettingSectionView: View {
    let section: SettingSection
    
    var onLogout: () -> Void = {}
    var onWithdraw: () -> Void = {}
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(section.header)
                .fontName(.homeSemibold12)
                .foregroundStyle(Color.gray800)
                .padding(.horizontal, 20)

            let items = section.items
            
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                VStack(spacing: 0) {
                    if let destination = item.destination {
                        NavigationLink(destination: destination) {
                            SettingRow(title: item.title, rightText: item.rightText, showsChevron: item.showsChevron)
                        }
                        .padding(.horizontal, 20)
                    } else if item.title == "로그아웃" {
                        Button {
                            onLogout()
                        } label: {
                            SettingRow(title: item.title, rightText: item.rightText, showsChevron: item.showsChevron)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 20)
                        .accessibilityLabel("로그아웃")
                    } else if item.title == "회원탈퇴" {
                        Button {
                            onWithdraw()
                        } label: {
                            SettingRow(title: item.title, rightText: item.rightText, showsChevron: item.showsChevron)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 20)
                        .accessibilityLabel("회원탈퇴")
                    } else {
                        SettingRow(title: item.title, rightText: item.rightText, showsChevron: item.showsChevron)
                            .padding(.horizontal, 20)
                    }
                    
                    if item.showDivider && index < items.count {
                        Divider()
                            .padding(.horizontal, 20)
                    }
                }
            }
        }
    }
}


struct SettingRow: View {
    let title: String
    let rightText: String?
    let showsChevron: Bool

    var body: some View {
        HStack {
            Text(title)
                .fontName(.captionSemibold14)
                .foregroundStyle(Color.black100)
                .padding(.vertical, 14)
            //피그마에서는 10pt간격인데 임의로 수정
            
            Spacer()

            if let rightText = rightText {
                Text(rightText)
                    .font(.caption)
                    .foregroundStyle(Color.gray200)
            } else if showsChevron {
                Image("Vector")
                    .resizable()
                    .frame(width: 6, height: 10)
            }
        }
        .contentShape(Rectangle())
    }
}



#Preview {
    SettingView()
}
