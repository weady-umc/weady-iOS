import SwiftUI

struct NavBtn: View {
    let title: String
    var isRequired: Bool = false
    var destination: () -> AnyView

    var body: some View {
        NavigationLink(destination: destination()) {
            HStack {
                Text(title)
                    .fontName(.bodySemibold16)
                    .foregroundStyle(Color.black100)
                if isRequired {
                    Text("*")
                        .foregroundStyle(Color.red)
                        .fontName(.bodySemibold16)
                }
                Spacer()
                Image(.vector)
                    .resizable()
                    .frame(width: 7, height: 12)
                    .foregroundStyle(Color.gray100)
            }
            .padding(.vertical, 5)
        }
    }
}
