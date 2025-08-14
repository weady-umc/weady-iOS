import SwiftUI

struct MyPageFilter: View {
    @Binding var selectedFilter: String
    
    private let filters = ["전체보기", "공개보기", "나만보기"]
    
    var body: some View {
        Menu {
            ForEach(filters, id: \.self) { filter in
                Button(action: { selectedFilter = filter }) {
                    Text(filter)
                        .background(selectedFilter == filter ? Color.gray500 : Color.clear)
                        
                }
            }
        } label: {
            HStack {
                Text(selectedFilter)
                    .fontName(.captionSemibold14)
                    .foregroundStyle(Color.black100)
                Image(systemName: "chevron.down")
                    .foregroundStyle(Color.black100)
            }
            .padding(.horizontal, 1)
            .padding(.vertical, 3)
        }
        
    }
}
