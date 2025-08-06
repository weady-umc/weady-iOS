////
////  View+Extensions.swift
////  weady
////
////  Created by 엄민서 on 7/27/25.
////
//
//import SwiftUI
//
//// MARK: - MASK : 특정 코너만 둥글게 만드는 Shape 구조체
//struct RoundedCorner: Shape {
//    var radius: CGFloat
//    var corners: UIRectCorner
//
//    func path(in rect: CGRect) -> Path {
//        let path = UIBezierPath(
//            roundedRect: rect,
//            byRoundingCorners: corners,
//            cornerRadii: CGSize(width: radius, height: radius)
//        )
//        return Path(path.cgPath)
//    }
//}
//
//// MARK: - View Extension
//extension View {
//    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
//        self.clipShape(RoundedCorner(radius: radius, corners: corners))
//    }
//}
