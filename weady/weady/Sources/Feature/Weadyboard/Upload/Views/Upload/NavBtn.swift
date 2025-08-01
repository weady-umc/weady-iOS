import SwiftUI

struct NavBtn: View {
    let title: String
    var isRequired: Bool = false
    var destination: () -> AnyView

    var body: some View {
        NavigationLink(destination: destination()) {
            HStack {
                Text(title)
                    .foregroundColor(.primary)
                if isRequired {
                    Text("*").foregroundColor(.red)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 12)
        }
    }
}
