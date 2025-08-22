import SwiftUI

struct MypageBoardDetailView: View {
    var boards: [MypageBoardDetailModel]
    @Binding var isPresented: Bool
    @State private var currentIndex: Int = 0 // 이미지 스크롤 현재 인디케이터
    @State private var selectedBoard: MypageBoardDetailModel
    
    init(boards: [MypageBoardDetailModel], isPresented: Binding<Bool>) {
            self.boards = boards
            self._isPresented = isPresented
            // 초기 선택 보드 설정
            self._selectedBoard = State(initialValue: boards.first!)
        }
    
    var body: some View {
        ZStack {
            // MARK: - 배경
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture { withAnimation { isPresented = false } }
            
            // MARK: - 공개/비공개 버튼 + 보드뷰(날짜+이미지)
            ZStack(alignment: .topLeading) {
                // 카드
                VStack(spacing: 0) {
                    boardCard(selectedBoard)
                }
                .frame(width: 335, height: 475)
                .background(Color.white100)
                .cornerRadius(8)
                
                // 공개/비공개 버튼
                HStack(spacing: 0) {
                    ForEach(boards, id: \.boardId) { board in
                        Button(action: { selectedBoard = board; currentIndex = 0 }) {
                            HStack(spacing: 4) {
                                Image(board.isPublic ? "publicIcon" : "privateIcon")
                                    .resizable()
                                    .frame(width: 11, height: 11)
                                Text(board.isPublic ? "공유중" : "보관중")
                                    .fontName(.homeMedium11)
                                    .foregroundStyle(Color.gray900)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(selectedBoard.boardId == board.boardId ? Color.white : Color.gray300)
                            .cornerRadius(2)
                        }
                    }
                }
                .offset(x: 4, y: -21)
            }
            .padding()
        }
    }
    
    private func boardCard(_ board: MypageBoardDetailModel) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // MARK: - 작성 날짜 텍스트
            Text(board.formattedCreatedAt)
                .fontName(.bodyMedium16)
                .foregroundStyle(Color.black100)
                .padding(.top, 15)
            
            // MARK: - 이미지 가로 스크롤뷰 + 인디케이터
            VStack(spacing: 14) {
                TabView(selection: $currentIndex) {
                    ForEach(board.imageList.indices, id: \.self) { index in
                        let image = board.imageList[index]
                        
                        // 이미지 클릭시, 실제 게시물뷰로 이동
                        NavigationLink(
                            destination: WeadyboardPostView(boardId: board.boardId, isTabBarHidden: .constant(false))
                        )
                        { AsyncImage(url: URL(string: image.imgUrl)) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                        .frame(width: 295, height: 370)
                                case .success(let img):
                                    img.resizable()
                                       .scaledToFit()
                                       .frame(maxWidth: 295, maxHeight: 370)
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
                            .fill(currentIndex == index ? Color.black10 : Color.white400)
                            .frame(width: 7, height: 7)
                    }
                }
            }
        }
        .padding(.bottom, 12)
    }
}

// MARK: - 날짜 포맷 확장
extension MypageBoardDetailModel {
    var createdAtDate: Date? {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        df.timeZone = TimeZone(secondsFromGMT: 0)
        return df.date(from: createdAt)
    }

    var formattedCreatedAt: String {
        guard let date = createdAtDate else { return createdAt }
        let df = DateFormatter()
        df.dateFormat = "yyyy년MM월dd일"
        return df.string(from: date)
    }
}
