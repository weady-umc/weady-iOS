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
    var showAlarmButton: Bool = false
    var backAction: (() -> Void)? = nil
    var alarmAction: (() -> Void)? = nil

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
                } else {
                    Spacer().frame(width: 44, height: 44)
                }
            }
            .padding(.horizontal, 15)
            .padding(.top, 15)

            Rectangle()
                .fill(Color.gray700)
                .frame(height: 1)
        }
        .background(Color.white100)
    }
}

#Preview {
    CustomNavBar(viewTitle: "위치")
}
