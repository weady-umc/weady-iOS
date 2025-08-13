//
//  KeyboardObserver.swift
//  weady
//
//  Created by 엄민서 on 7/17/25.
//

import Combine
import SwiftUI
import UIKit

final class KeyboardObserver: ObservableObject {
    @Published var height: CGFloat = 0
    @Published var duration: Double = 0.25
    @Published var curve: UIView.AnimationCurve = .easeInOut

    private var cancellables: Set<AnyCancellable> = []

    init() {
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .merge(with: NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification))
            .compactMap { Self.parse(notification: $0) }
            .sink { [weak self] payload in
                guard let self else { return }
                self.duration = payload.duration
                self.curve = payload.curve
                let screenH = UIScreen.main.bounds.height
                let h = max(0, screenH - payload.endFrame.origin.y)
                self.height = h
            }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .compactMap { Self.parse(notification: $0) }
            .sink { [weak self] payload in
                guard let self else { return }
                self.duration = payload.duration
                self.curve = payload.curve
                self.height = 0
            }
            .store(in: &cancellables)
    }

    private static func parse(notification: Notification) -> (endFrame: CGRect, duration: Double, curve: UIView.AnimationCurve)? {
        guard
            let info = notification.userInfo,
            let frame = info[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        else { return nil }

        let duration = (info[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.25
        let curveRaw = (info[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.intValue ?? UIView.AnimationCurve.easeInOut.rawValue
        let curve = UIView.AnimationCurve(rawValue: curveRaw) ?? .easeInOut

        return (frame, duration, curve)
    }
}

// MARK: - Safe Area Inset Helper
extension UIApplication {
    static var bottomSafeAreaInset: CGFloat {
        let window = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
        return window?.safeAreaInsets.bottom ?? 0
    }
}
