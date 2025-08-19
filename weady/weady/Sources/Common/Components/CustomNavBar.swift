//
//  CustomNavBar.swift
//  weady
//
//  Created by 엄민서 on 7/10/25.
//

import SwiftUI

struct CustomNavBar: View {
    let viewTitle: String
    var showBackButton: Bool = false
    var showLogoButton: Bool = false
    var showAlarmButton: Bool = false
    var showSubmitButton: Bool = false
    var showBottomDivider: Bool = true
    var backAction: (() -> Void)? = nil
    var logoAction: (() -> Void)? = nil
    var alarmAction: (() -> Void)? = nil
    var submitAction: (() -> Void)? = nil
    
    var logoImageName: String = "navbar_logo"

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                if showBackButton {
                    Button(action: {
                        backAction?()
                    }) {
                        Image("backicon")
                            .resizable()
                            .frame(width: 9.5, height: 17)
                            .frame(width: 44, height: 44)
                    }
                } else if showLogoButton {
                    Button(action: { logoAction?() }) {
                        Image(logoImageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 59, height: 25)
                            
                    }
                        
                } else {
                    Spacer().frame(width: 44, height: 44)
                }

                Spacer()

                Text(viewTitle)
                    .fontName(.bodySemibold16)

                Spacer()

                if showAlarmButton {
                    Button(action: {
                        alarmAction?()
                    }) {
                        Image("alarmicon")
                            .resizable()
                            .frame(width: 18, height: 20)
                            .frame(width: 44, height: 44)
                    }
                } else if showSubmitButton {
                    Button(action: {
                        submitAction?()
                    }) {
                        Text("완료")
                            .fontName(.captionMedium14)
                            .foregroundStyle(Color.black100)
                            .frame(width: 44, height: 44)
                    }
                } else {
                    Spacer().frame(width: 44, height: 44)
                }
            }
            .padding(.horizontal, 15)
            .padding(.top, 15)
            
            // 네비게이션바 아래에 선 있으면 true로 설정
            if showBottomDivider {
                Rectangle()
                    .fill(Color.gray700)
                    .frame(height: 1)
            }
        }
        .background(Color.white100)
    }
}

#Preview {
    CustomNavBar(viewTitle: "위치")
}
