//
//  View+Extensions.swift
//  weady
//
//  Created by 엄민서 on 7/27/25.
//

import SwiftUI

// MARK: - MASK : 특정 코너만 둥글게 만드는 Shape 구조체
struct RoundedCorner: Shape {
    var radius: CGFloat
    var corners: UIRectCorner

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - View Extension
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        self.clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

extension UIApplication {
    func topViewController(controller: UIViewController? = UIApplication.shared.connectedScenes
        .compactMap { ($0 as? UIWindowScene)?.keyWindow }
        .first?.rootViewController) -> UIViewController? {

        if let nav = controller as? UINavigationController {
            return topViewController(controller: nav.visibleViewController)
        }

        if let tab = controller as? UITabBarController,
           let selected = tab.selectedViewController {
            return topViewController(controller: selected)
        }

        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }

        return controller
    }
}

/// 현재 기기의 화면 너비를 iPhone 13 mini(375pt) 기준으로 환산한 스케일 값
   ///
   /// - 사용 예시:
   ///   - 디자인을 13 mini 기준으로 작업했을 때,
   ///     다른 기기에서는 이 값을 곱해서 여백, 간격, 크기를 비율대로 조정할 수 있음
   ///
   /// 예) padding을 8로 지정했으면 → `8 * .deviceScale`
   ///     iPhone 16 Pro(393pt)에서는 약 8.4pt로 자동 조정됨
   ///
///

// 기준 스케일 값 
extension CGFloat {
    static var baseScale: CGFloat {
        UIScreen.main.bounds.width / 375.0
    }
    static var deviceHeightScale: CGFloat {
        UIScreen.main.bounds.height / 812.0
    }
}

// CGFloat
extension CGFloat {
    static var deviceScale: CGFloat { baseScale }
}

// Double
extension Double {
    static var deviceScale: CGFloat { CGFloat.baseScale }
}

// Int
extension Int {
    static var deviceScale: CGFloat { CGFloat.baseScale }
}
