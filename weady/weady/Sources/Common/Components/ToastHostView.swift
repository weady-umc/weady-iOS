//
//  ToastHostView.swift
//  weady
//
//  Created by 엄민서 on 8/9/25.
//

import SwiftUI

public struct ToastHostView: View {
    @EnvironmentObject private var toastCenter: ToastCenter
    
    public init() {}
    
    public var body: some View {
        GeometryReader { proxy in
            VStack {
                Spacer()
                if let toast = toastCenter.current {
                    ToastView(message: toast.message, style: toast.style)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .padding(.bottom, 16 + proxy.safeAreaInsets.bottom)
                        .padding(.horizontal, 24)
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel(Text(toast.message))
                        .onTapGesture {
                            toastCenter.dismiss()
                        }
                        .highPriorityGesture(
                            DragGesture(minimumDistance: 20)
                                .onEnded { value in
                                    if value.translation.height > 10 {
                                        toastCenter.dismiss()
                                    }
                                }
                        )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .animation(.easeInOut(duration: 0.25), value: toastCenter.current)
            .allowsHitTesting(true)
        }
        .ignoresSafeArea()
    }
}

public struct ToastView: View {
    let message: String
    let style: ToastStyle
    
    public init(message: String, style: ToastStyle) {
        self.message = message
        self.style = style
    }
    
    public var body: some View {
        Text(message)
            .fontName(.captionRegular14)
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(style.background)
            )
            .fixedSize(horizontal: false, vertical: true)
            .shadow(radius: 6)
    }
}

public struct ToastHostModifier: ViewModifier {
    @EnvironmentObject private var toastCenter: ToastCenter
    
    public func body(content: Content) -> some View {
        content
            .overlay(alignment: .bottom) {
                ToastHostView()
                    .environmentObject(toastCenter)
            }
    }
}

public extension View {
    func toastHost() -> some View {
        self
            .environmentObject(ToastCenter.shared)
            .modifier(ToastHostModifier())
    }
}
