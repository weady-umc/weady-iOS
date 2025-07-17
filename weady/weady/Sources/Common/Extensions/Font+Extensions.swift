//
//  Font+Extensions.swift
//  weady
//
//  Created by 엄민서 on 7/9/25.
//

import SwiftUI

enum AppTextStyle {
    case titleBold24, titleSemibold24, titleMedium24
    case headingBold20, headingSemibold20, headingMedium20, headingRegular20
    case bodySemibold16, bodyMedium16, bodyRegular16, bodyLight16
    case captionSemibold14, captionMedium14, captionRegular14, captionLight14
    case metaSemibold12, metaMedium12, metaRegular12
    case metaMedium10, metaRegular10, metaMedium8, metaRegular8
    case homeRegular30, homeMedium11, homeRegular11

    var font: Font {
        switch self {
        case .titleBold24: return .custom("Pretendard-Bold", size: 24)
        case .titleSemibold24: return .custom("Pretendard-SemiBold", size: 24)
        case .titleMedium24: return .custom("Pretendard-Medium", size: 24)

        case .headingBold20: return .custom("Pretendard-Bold", size: 20)
        case .headingSemibold20: return .custom("Pretendard-SemiBold", size: 20)
        case .headingMedium20: return .custom("Pretendard-Medium", size: 20)
        case .headingRegular20: return .custom("Pretendard-Regular", size: 20)

        case .bodySemibold16: return .custom("Pretendard-SemiBold", size: 16)
        case .bodyMedium16: return .custom("Pretendard-Medium", size: 16)
        case .bodyRegular16: return .custom("Pretendard-Regular", size: 16)
        case .bodyLight16: return .custom("Pretendard-Light", size: 16)

        case .captionSemibold14: return .custom("Pretendard-SemiBold", size: 14)
        case .captionMedium14: return .custom("Pretendard-Medium", size: 14)
        case .captionRegular14: return .custom("Pretendard-Regular", size: 14)
        case .captionLight14: return .custom("Pretendard-Light", size: 14)

        case .metaSemibold12: return .custom("Pretendard-SemiBold", size: 12)
        case .metaMedium12: return .custom("Pretendard-Medium", size: 12)
        case .metaRegular12: return .custom("Pretendard-Regular", size: 12)
        case .metaMedium10: return .custom("Pretendard-Medium", size: 10)
        case .metaRegular10: return .custom("Pretendard-Regular", size: 10)
        case .metaMedium8: return .custom("Pretendard-Medium", size: 8)
        case .metaRegular8: return .custom("Pretendard-Regular", size: 8)

        case .homeRegular30: return .custom("Pretendard-SemiBold", size: 30)
        case .homeMedium11: return .custom("Pretendard-Medium", size: 11)
        case .homeRegular11: return .custom("Pretendard-Regular", size: 11)
        }
    }

    var fontSize: CGFloat {
        switch self {
        case .titleBold24, .titleSemibold24, .titleMedium24: return 24
        case .headingBold20, .headingSemibold20, .headingMedium20, .headingRegular20: return 20
        case .bodySemibold16, .bodyMedium16, .bodyRegular16, .bodyLight16: return 16
        case .captionSemibold14, .captionMedium14, .captionRegular14, .captionLight14: return 14
        case .metaSemibold12, .metaMedium12, .metaRegular12: return 12
        case .metaMedium10, .metaRegular10: return 10
        case .metaMedium8, .metaRegular8: return 8
        case .homeRegular30: return 30
        case .homeMedium11, .homeRegular11: return 11
        }
    }

    var lineHeight: CGFloat {
        switch self {
        case .titleBold24, .titleSemibold24, .titleMedium24: return 35
        case .headingBold20, .headingSemibold20, .headingMedium20, .headingRegular20: return 28
        case .bodySemibold16, .bodyMedium16, .bodyRegular16, .bodyLight16: return 24
        case .captionSemibold14, .captionMedium14, .captionRegular14, .captionLight14: return 20
        case .metaSemibold12, .metaMedium12, .metaRegular12,
             .metaMedium10, .metaRegular10,
             .metaMedium8, .metaRegular8: return 16
        case .homeRegular30: return 30
        case .homeMedium11, .homeRegular11: return 11
        }
    }

    var letterSpacingPercent: CGFloat {
        switch self {
        case .bodySemibold16, .bodyMedium16, .bodyRegular16, .bodyLight16: return -1
        case .captionSemibold14, .captionMedium14, .captionRegular14, .captionLight14: return -2
        case .homeMedium11, .homeRegular11: return -1
        default: return 0
        }
    }
}

extension View {
    func fontName(_ style: AppTextStyle) -> some View {
        let spacing = style.lineHeight - style.fontSize
        let tracking = style.fontSize * style.letterSpacingPercent / 100
        return self
            .font(style.font)
            .lineSpacing(spacing)
            .tracking(tracking)
    }
}
