//
//  LoginView.swift
//  weady
//
//  Created by 엄민서 on 7/29/25.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @Environment(NavigationRouter.self) private var router
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Text("Weady")
                .font(.largeTitle)
                .bold()
            
            Spacer()
            
            Button {
                viewModel.loginWithKakao {
                    router.push(.basetab)
                }
            } label: {
                HStack {
                    Image("kakao_icon")
                    Text("카카오로 로그인")
                        .font(.headline)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.yellow)
                .cornerRadius(10)
            }
            
            Button {
                viewModel.loginWithGoogle {
                    router.push(.basetab)
                }
            } label: {
                HStack {
                    Image("google_icon")
                    Text("구글로 로그인")
                        .font(.headline)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray))
            }
            
            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding(.top, 10)
            }
            
            Spacer()
        }
        .padding(.horizontal, 24)
    }
}
