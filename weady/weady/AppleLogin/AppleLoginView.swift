//
//  AppleLoginView.swift
//  weady
//
//  Created by 엄민서 on 8/18/25.
//

import SwiftUI
import AuthenticationServices

struct AppleLoginView: View {
    @State var viewModel: AppleLoginViewModel = .init()
    
    var body: some View {
        VStack(spacing: 20, content: {
            SignInWithAppleButton(
                onRequest: { _ in },
                onCompletion: { _ in }
            )
            .frame(width: 100, height: 30)
            .onTapGesture {
                Task {
                    if let window = UIApplication.shared.connectedScenes
                        .compactMap({ $0 as? UIWindowScene })
                        .first?.windows.first {
                        await viewModel.loginWithApple(presentationAnchor: window)
                    }
                }
            }
            
            if viewModel.isLoggedIn {
                Text("환영합니다, \(viewModel.fullName)")
            }
        })
    }
}

#Preview {
    AppleLoginView()
}
