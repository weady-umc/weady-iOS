//
//  MyInfoView.swift
//  weady
//
//  Created by 김영택 on 7/17/25.
//

import SwiftUI

struct MyInfoView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = MyInfoViewModel()

    var body: some View {
    
            VStack(alignment: .leading) {
                // 로그인 정보
                VStack(alignment: .leading) {
                    Text("로그인 정보")
                        .font(AppTextStyle.captionSemibold14.font)
                    Spacer().frame(height: 24)

                    VStack(alignment: .leading) {
                        Text("아이디(이메일)")
                            .font(AppTextStyle.homeSemibold12.font)
                            .foregroundColor(.gray900)
                        Spacer().frame(height: 14)

                        Text(viewModel.userInfo.email)
                            .font(AppTextStyle.metaSemibold12.font)
                            .foregroundColor(.black)
                        Spacer().frame(height: 14)

                        Divider()

                        if viewModel.userInfo.isSocialLogin {
                            Text("카카오로 가입한 계정이에요.")
                                .font(AppTextStyle.metaMedium8.font)
                                .foregroundColor(.gray800)
                        }
                    }
                }

                Spacer().frame(height: 42)

                // 회원 정보
                VStack(alignment: .leading) {
                    Text("회원 정보")
                        .font(AppTextStyle.captionSemibold14.font)
                    Spacer().frame(height: 24)

                    VStack(spacing: 12) {
                        VStack(alignment: .leading) {
                            Text("성명")
                                .font(AppTextStyle.homeSemibold12.font)
                                .foregroundColor(.gray900)
                            Spacer().frame(height: 14)

                            Text(viewModel.userInfo.name)
                                .font(AppTextStyle.metaSemibold12.font)
                                .foregroundColor(.black)
                            Spacer().frame(height: 14)

                            Divider()
                        }

                        VStack(alignment: .leading) {
                            Text("연락처")
                                .font(AppTextStyle.homeSemibold12.font)
                                .foregroundColor(.gray900)
                            Spacer().frame(height: 14)

                            Text(viewModel.userInfo.phone)
                                .font(AppTextStyle.metaSemibold12.font)
                                .foregroundColor(.black)
                            Spacer().frame(height: 14)

                            Divider()
                            Spacer().frame(height: 2)
                        }

                        Button(action: {
                            viewModel.verifyIdentity()
                        }) {
                            Text("본인 인증으로 정보 수정하기")
                                .font(AppTextStyle.metaMedium12.font)
                                .foregroundColor(.gray900)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(Color.gray, lineWidth: 1)
                                )
                        }
                        .foregroundColor(.gray900)
                    }
                }

                Spacer().frame(height: 22)

                // 성별 선택
                VStack(alignment: .leading) {
                    Text("성별")
                        .font(AppTextStyle.homeSemibold12.font)
                        .foregroundColor(.gray900)

                    HStack(spacing: 23) {
                        ForEach(Gender.allCases, id: \.self) { gender in
                            HStack(spacing: 8) {
                                if viewModel.userInfo.gender == gender {
                                    Image("check")
                                        .resizable()
                                        .frame(width: 18, height: 18)
                                } else {
                                    Circle()
                                        .strokeBorder(Color.gray500, lineWidth: 1.5)
                                        .frame(width: 18, height: 18)
                                }

                                Text(gender.label)
                                    .font(AppTextStyle.metaSemibold12.font)
                                    .foregroundStyle(.black)
                            }
                            .onTapGesture {
                                viewModel.updateGender(to: gender)
                            }
                        }
                    }
                    .padding(.leading, 10)
                }

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 44)
        
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)
                }
            }
        }
        .navigationTitle("내 정보 관리")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.white)
    }
}

// 미리보기
#Preview {
    NavigationView {
        MyInfoView()
    }
}
