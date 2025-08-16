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
            ZStack {
                Text(viewTitle)
                    .fontName(.bodySemibold16)

                // 좌우 컨트롤 레이어
                HStack {
                    // 왼쪽: Back / Logo / 빈 자리
                    if showBackButton {
                        Button(action: { backAction?() }) {
                            Image("backicon")
                                .resizable()
                                .frame(width: 9.5, height: 17)
                                .frame(width: 44, height: 44, alignment: .leading)
                                .contentShape(Rectangle())
                        }
                    } else if showLogoButton {
                        Button(action: { logoAction?() }) {
                            Image(logoImageName)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 25)
                                // 44영역의 leading 정렬
                                .frame(width: 44, height: 44, alignment: .leading)
                                .contentShape(Rectangle())
                        }
                    } else {
                        // 자리 유지용 투명 뷰
                        Color.clear.frame(width: 44, height: 44)
                    }

                    Spacer()

                    // 오른쪽: Alarm / Submit / 빈 자리
                    if showAlarmButton {
                        Button(action: { alarmAction?() }) {
                            Image("alarmicon")
                                .resizable()
                                .frame(width: 20, height: 22)
                                .frame(width: 44, height: 44, alignment: .trailing)
                                .contentShape(Rectangle())
                        }
                    } else if showSubmitButton {
                        Button(action: { submitAction?() }) {
                            Text("완료")
                                .fontName(.captionMedium14)
                                .foregroundStyle(Color.black100)
                                .frame(width: 44, height: 44, alignment: .trailing)
                                .contentShape(Rectangle())
                        }
                    } else {
                        Color.clear.frame(width: 44, height: 44)
                    }
                }
            }
            .padding(.horizontal, 20)
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
