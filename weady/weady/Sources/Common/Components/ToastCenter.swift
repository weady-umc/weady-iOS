//
//  ToastCenter.swift
//  weady
//
//  Created by 엄민서 on 8/10/25.
//

import SwiftUI
import Combine
import UIKit

public enum ToastStyle: Equatable {
    case normal
    case success
    case error
    
    var background: Color {
        switch self {
        case .normal:  return Color.black.opacity(0.85)
        case .success: return Color.green.opacity(0.90)
        case .error:   return Color.red.opacity(0.90)
        }
    }
}

public struct ToastItem: Identifiable, Equatable {
    public let id = UUID()
    public let message: String
    public let style: ToastStyle
    public let duration: TimeInterval
    public let haptic: Bool
    
    public init(message: String,
                style: ToastStyle = .normal,
                duration: TimeInterval = 2.0,
                haptic: Bool = false) {
        self.message = message
        self.style = style
        self.duration = duration
        self.haptic = haptic
    }
}

@MainActor
public final class ToastCenter: ObservableObject {
    public static let shared = ToastCenter()
    
    @Published public var current: ToastItem?
    
    private var queue: [ToastItem] = []
    private var hideWorkItem: DispatchWorkItem?
    
    private init() {}
    
    public func show(_ message: String,
                     style: ToastStyle = .normal,
                     duration: TimeInterval = 2.0,
                     haptic: Bool = false) {
        let incoming = ToastItem(message: message, style: style, duration: duration, haptic: haptic)
        
        if let cur = current, cur.message == incoming.message, cur.style == incoming.style {
            extendCurrent(by: duration * 0.6)
            return
        }
        
        queue.append(incoming)
        presentNextIfNeeded()
    }
    
    public func showSuccess(_ message: String, duration: TimeInterval = 2.0, haptic: Bool = true) {
        show(message, style: .success, duration: duration, haptic: haptic)
    }
    
    public func showError(_ message: String, duration: TimeInterval = 2.0, haptic: Bool = true) {
        show(message, style: .error, duration: duration, haptic: haptic)
    }
    
    public func dismiss(animated: Bool = true) {
        hideWorkItem?.cancel()
        if animated {
            withAnimation(.easeInOut(duration: 0.25)) {
                current = nil
            }
        } else {
            current = nil
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.26) { [weak self] in
            Task { @MainActor in
                self?.presentNextIfNeeded()
            }
        }
    }
    
    private func presentNextIfNeeded() {
        guard current == nil, !queue.isEmpty else { return }
        let next = queue.removeFirst()
        
        if next.haptic {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
        
        withAnimation(.easeInOut(duration: 0.25)) {
            current = next
        }
        
        scheduleAutoHide(after: next.duration)
    }
    
    private func scheduleAutoHide(after duration: TimeInterval) {
        hideWorkItem?.cancel()
        let work = DispatchWorkItem { [weak self] in
            Task { @MainActor in
                withAnimation(.easeInOut(duration: 0.25)) {
                    self?.current = nil
                }
                self?.presentNextIfNeeded()
            }
        }
        hideWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: work)
    }
    
    private func extendCurrent(by seconds: TimeInterval) {
        guard let cur = current else { return }
        let extended = ToastItem(message: cur.message,
                                 style: cur.style,
                                 duration: cur.duration + max(0.5, seconds),
                                 haptic: cur.haptic)
        current = extended
        scheduleAutoHide(after: extended.duration)
    }
}
