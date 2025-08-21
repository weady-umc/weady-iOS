import SwiftUI

struct OverlayBanner: View {
    let imgName: String
    let text: String
    
    var body: some View {
        HStack(spacing: 0) {
            Image(imgName)
                .resizable()
                .scaledToFit()
                .frame(width: 18, height: 18)
                .padding(10)
            
            Text(text)
                .fontName(.captionMedium14)
                .foregroundStyle(Color.white100)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
        .background(Color.black50)
        .cornerRadius(10)
        .padding(.horizontal, 20)
    }
}
