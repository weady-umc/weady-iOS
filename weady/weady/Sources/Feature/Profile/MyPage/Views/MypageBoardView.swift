import SwiftUI

struct MypageBoardView: View {
    let board: MypageBoardDetailModel
    @Binding var isPresented: Bool
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let date = board.createdAtDate {
            return formatter.string(from: date)
        }
        return board.createdAt.prefix(10).description
    }
    
    var body: some View {
        VStack(spacing: 8) {
            //MARK: - 상단 헤더
            HStack {
                Text("\(formattedDate) 게시물")
                    .font(.body)
                Spacer()
                Button {
                    isPresented = false
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal)
            
            //MARK: - 게시물 이미지 스크롤
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(board.imageList.indices, id: \.self) { idx in
                        boardImage(idx: idx)
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical, 10)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 5)
        .padding(.horizontal, 12)
    }
    
    // 게시물 이미지 뷰
    @ViewBuilder
    private func boardImage(idx: Int) -> some View {
        let imgUrl = board.imageList[idx].imgUrl
        let boardId = board.boardId

        NavigationLink(destination: WeadyboardPostView(boardId: boardId, isTabBarHidden: .constant(false))) {
            AsyncImage(url: URL(string: imgUrl)) { img in
                img.resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.gray.opacity(0.2)
            }
            .frame(width: 120, height: 120)
            .cornerRadius(8)
        }
    }
}
