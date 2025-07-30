import SwiftUI

struct GradientSliderView: View {
    @Binding var index: Int      
    let steps: Int = 8

    private let gradientStart = Color(hex: "09065F")
    private let gradientEnd   = Color(hex: "FF4F4F")

    private func handleColor(for idx: Int) -> Color {
        switch idx {
        case 0: return Color(hex: "09065F")
        case 1: return Color(hex: "1A237E")
        case 2: return Color(hex: "3949AB")
        case 3: return Color(hex: "5C6BC0")
        case 4: return Color(hex: "FFB74D")
        case 5: return Color(hex: "FF8A65")
        case 6: return Color(hex: "FF7043")
        default: return Color(hex: "FF4F4F")
        }
    }

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let handleSize: CGFloat = 11
            let trackHeight: CGFloat = 4
            let usableWidth = width - handleSize
            let stepSpacing = usableWidth / CGFloat(steps - 1)
            let handleX = CGFloat(index) * stepSpacing

            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: trackHeight/2)
                    .fill(Color.gray400)
                    .frame(height: trackHeight)

                LinearGradient(
                    stops: [
                        .init(color: gradientStart, location: 0.0),
                        .init(color: gradientEnd,   location: 1.0)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(width: handleX + handleSize/2, height: trackHeight)
                .clipShape(RoundedRectangle(cornerRadius: trackHeight/2))

                Circle()
                    .fill(Color.white100)
                    .frame(width: handleSize, height: handleSize)
                    .overlay(Circle().stroke(Color.black100))
                    .offset(x: handleX)
                    .gesture(
                        DragGesture()
                            .onChanged { g in
                                let x = g.location.x
                                let clamped = min(max(0, x - handleSize/2), usableWidth)
                                let raw = clamped / stepSpacing
                                let snapped = Int((raw).rounded())
                                index = max(0, min(steps - 1, snapped))
                            }
                    )
            }
        }
        .frame(height: 30)
    }
}
