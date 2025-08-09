import SwiftUI

struct GradientSlider: View {
    @Binding var value: Double
    let steps = 8

    private var percent: CGFloat {
        CGFloat(value) / CGFloat(steps - 1)
    }

    private var handleColor: Color {
        switch Int(value) {
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
                        .init(color: Color(hex: "09065F"), location: 0.0),
                        .init(color: Color(hex: "FF4F4F"), location: 1.0)
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
                                let ratio = clampedX / (width - handleSize)
                                let index = Int(round(ratio * CGFloat(steps - 1)))
                                value = Double(index)
                            }
                    )
            }
        }
        .frame(height: 30)
    }
}
