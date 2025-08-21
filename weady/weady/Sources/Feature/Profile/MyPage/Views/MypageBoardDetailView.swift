import SwiftUI

struct MypageBoardDetailView: View {
    let board: MypageBoardDetailModel
    @Binding var isPresented: Bool
    @State private var currentIndex: Int = 0 // 이미지 스크롤 현재 인디케이터
    
    var body: some View {
        ZStack {
            // MARK: - 배경
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation { isPresented = false }
                }
            
            // MARK: - 공개/비공개 버튼 + 보드뷰(날짜+이미지)
            ZStack(alignment: .topLeading) {
                // 카드
                VStack(spacing: 0) {
                    boardCard(board)
                }
                .frame(width: 335, height: 475)
                .background(Color.white)
                .cornerRadius(8)
                
                // 공개/비공개 버튼
                Button(action: {
                    // TODO: 버튼 액션 필요 시 구현
                }) {
                    HStack(spacing: 4) {
                        Image(board.isPublic ? "publicIcon" : "privateIcon")
                            .resizable()
                            .frame(width: 11, height: 11)
                        Text(board.isPublic ? "공유중" : "보관중")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.white)
                    .cornerRadius(4)
                    .shadow(radius: 1)
                }
                .offset(x: 4, y: -15)
            }
            .padding()
        }
    }
    
    private func boardCard(_ board: MypageBoardDetailModel) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // MARK: - 작성 날짜 (yyyy-MM-dd)
            Text(board.createdAt.prefix(10))
                .fontName(.bodyMedium16)
                .foregroundStyle(Color.black100)
                .padding(.top, 15)
            
            // MARK: - 이미지 가로 스크롤뷰 + 인디케이터
            ZStack(alignment: .bottom) {
                TabView(selection: $currentIndex) {
                    ForEach(board.imageList.indices, id: \.self) { index in
                        let image = board.imageList[index]
                        NavigationLink(
                            destination: WeadyboardPostView(boardId: board.boardId, isTabBarHidden: .constant(false))
                        ) {
                            AsyncImage(url: URL(string: image.imgUrl)) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                        .frame(width: 295, height: 370)
                                case .success(let img):
                                    img .resizable()
                                        .scaledToFit()
                                        .frame(width: 295, height: 370)
                                case .failure(_):
                                    ProgressView()
                                        .frame(width: 295, height: 370)
                                @unknown default:
                                    EmptyView()
                                }
                            }
                        }
                        .tag(index)
                    }
                }
                .frame(width: 295, height: 370)
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                // MARK: - 이미지 스크롤뷰 인디케이터
                HStack(spacing: 6) {
                    ForEach(board.imageList.indices, id: \.self) { index in
                        Circle()
                            .fill(currentIndex == index ? Color.gray200 : Color.white400)
                            .frame(width: 7, height: 7)
                    }
                }
                .padding(.bottom, 14)
            }
        }
        .padding(.bottom, 12)
    }
}

extension MypageBoardDetailModel {
    var createdAtDate: Date? {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime]
        return isoFormatter.date(from: createdAt)
    }
}
