//
//  Color+Extensions.swift
//  weady
//
//  Created by 엄민서 on 7/9/25.
//

import SwiftUI

// MARK: - App Color Set
extension Color {
    // Black
    static let black100 = Color(hex: "#111111")
    static let black70  = Color(hex: "#111111B2")
    static let black50  = Color(hex: "#11111180")
    static let black30  = Color(hex: "#1111114D")
    static let black20  = Color(hex: "#11111133")
    static let black10  = Color(hex: "#1111111A")

    // Gray
    static let gray100 = Color(hex: "#333333")
    static let gray200 = Color(hex: "#666666")
    static let gray300 = Color(hex: "#999999")
    static let gray400 = Color(hex: "#D9D9D9")
    static let gray500 = Color(hex: "#E9E9E9")
    static let gray600 = Color(hex: "#EBEBEB")
    static let gray700 = Color(hex: "#E0E0E0")
    static let gray800 = Color(hex: "#C4C4C4")
    static let gray900 = Color(hex: "#777777")

    // White
    static let white100 = Color(hex: "#FFFFFF")
    static let white200 = Color(hex: "#FAFAFA")
    static let white300 = Color(hex: "#F5F5F5")
    static let white400 = Color(hex: "#F0F0F0")
    
    // icon
    static let sun = Color(hex: "FFD035")
    static let rain1 = Color(hex: "8BC7FF")
    static let rain2 = Color(hex: "F4FEFF")
    static let logo = Color(hex: "FFB300")
    
    // Login
    static let login100 = Color(hex: "FEE500")
    static let login200 = Color(hex: "E33629")
    static let login300 = Color(hex: "F8BD00")
    static let login400 = Color(hex: "319F43")
    static let login500 = Color(hex: "587DBD")

    // Default
    static let systemblue = Color(hex: "007AFF")
    static let systemred = Color(hex: "FF3B30")
    static let systemgreen = Color(hex: "34C759")
}

// MARK: - Hex 지원 생성자
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        var hexString = hex

        if hex.hasPrefix("#") {
            hexString = String(hex.dropFirst())
        }

        var int = UInt64()
        Scanner(string: hexString).scanHexInt64(&int)

        let r, g, b, a: Double

        switch hexString.count {
        case 6: // RRGGBB
            r = Double((int >> 16) & 0xFF) / 255.0
            g = Double((int >> 8) & 0xFF) / 255.0
            b = Double(int & 0xFF) / 255.0
            a = 1.0
        case 8: // RRGGBBAA
            r = Double((int >> 24) & 0xFF) / 255.0
            g = Double((int >> 16) & 0xFF) / 255.0
            b = Double((int >> 8) & 0xFF) / 255.0
            a = Double(int & 0xFF) / 255.0
        default:
            r = 0; g = 0; b = 0; a = 1
        }

        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
}
