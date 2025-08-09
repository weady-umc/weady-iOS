import SwiftUI

struct ToggleBtn: View {
    let label: String
    @Binding var isOn: Bool

    var body: some View {
        HStack {
            Text(label)
                .fontName(.bodySemibold16)
                .foregroundStyle(Color.black100)
            Spacer()
            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
    }
}
