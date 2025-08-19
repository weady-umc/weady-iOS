//
//  GradientSliderView.swift
//  weady
//
//  Created by 엄민서 on 7/24/25.
//

// 기온 슬라이더
import SwiftUI

struct GradientSliderView: View {
    @Binding var value: Double
    let range: ClosedRange<Double>

    private var percent: CGFloat {
        CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound))
    }

    private var handleColor: Color {
        switch Int(value) {
        case ..<(-5): return Color(hex: "09065F")
        case -5...5:  return Color(hex: "1A237E")
        case 6...11:  return Color(hex: "3949AB")
        case 12...16: return Color(hex: "5C6BC0")
        case 17...22: return Color(hex: "FFB74D")
        case 23...26: return Color(hex: "FF8A65")
        case 27...30: return Color(hex: "FF7043")
        default:      return Color(hex: "FF4F4F")
        }
    }

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let handleSize: CGFloat = 11
            let trackHeight: CGFloat = 4
            let handleX = percent * (width - handleSize)
            
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.gray400)
                    .frame(height: trackHeight)
                    .cornerRadius(trackHeight / 2)
                
                LinearGradient(
                    stops: [
                        .init(color: Color(hex: "09065F"), location: 0.22),
                        .init(color: Color(hex: "FF4F4F"), location: 0.78)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(width: handleX + handleSize / 2, height: trackHeight)
                .cornerRadius(trackHeight / 2)

                Circle()
                    .fill(Color.white100)
                    .frame(width: handleSize, height: handleSize)
                    .overlay(
                        Circle()
                            .stroke(Color.black100)
                    )
                    .offset(x: handleX)
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                let x = gesture.location.x
                                let clampedX = min(max(0, x), width - handleSize)
                                let newPercent = clampedX / (width - handleSize)
                                let newValue = Double(newPercent) * (range.upperBound - range.lowerBound) + range.lowerBound
                                value = newValue.rounded()
                            }
                    )
            }
        }
        .frame(height: 30 * .deviceScale)
    }
}
