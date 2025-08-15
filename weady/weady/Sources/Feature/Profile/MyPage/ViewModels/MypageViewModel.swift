import Foundation

@Observable
final class MypageViewModel {
    // 상태
    var year: Int
    var month: Int
    var selectedFilter: String = "전체보기"
    
    var profile: MypageProfileModel?
    var calendar: [CalendarThumbnailModel] = []
    
    var selectedDate: String? = nil
    var selectedBoard: MypageBoardDetailModel? = nil
    
    private let userService = UserService()
    
    // 초기화
    init() {
        let today = Date()
        let comps = Calendar.current.dateComponents([.year, .month], from: today)
        self.year = comps.year ?? 2025
        self.month = comps.month ?? 8
        
        fetchMypageData()
    }
    
    // 필터 적용
    var filterCalendar: [CalendarThumbnailModel] {
        switch selectedFilter {
        case "전체보기": return calendar
        case "공개보기": return calendar.filter { $0.isPublic }
        case "나만보기": return calendar.filter { !$0.isPublic }
        default: return calendar
        }
    }
    
    // 프로필 업데이트
    func updateProfile(_ newProfile: MypageProfileModel) {
        self.profile = newProfile
    }
    
    // MARK: - 마이페이지 조회
    func fetchMypageData() {
        userService.fetchMyPage(year: year, month: month) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self?.mapMyPageResponse(response)
                case .failure(let error):
                    print(">>> 마이페이지 불러오기 실패: \(error)")
                }
            }
        }
    }
    
    // MARK: - 특정 날짜 게시물 조회
    func fetchBoard(date: String, isPublic: Bool = true) {
        selectedDate = date
        userService.fetchBoard(date: date, isPublic: isPublic) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self?.mapBoardResponse(response)
                case .failure(let error):
                    self?.selectedBoard = nil
                    print(">>> 해당 날짜 게시물 조회 실패: \(error)")
                }
            }
        }
    }
    
    // DTO → UI 모델 변환
    private func mapMyPageResponse(_ dto: GetMyPageResponse) {
        profile = MypageProfileModel(
            id: dto.userId,
            name: dto.name,
            profileImageUrl: dto.profileImageUrl
        )
        
        calendar = dto.calendar.map {
            CalendarThumbnailModel(
                date: $0.date,
                thumbnailUrl: $0.thumbnailUrl,
                isPublic: true //TODO: - 현재 API에 없음 → 추후 백엔드 반영
            )
        }
    }
    
    private func mapBoardResponse(_ dto: GetBoardInMyPageResponse) {
        selectedBoard = MypageBoardDetailModel(
            boardId: dto.boardId,
            createdAt: dto.createdAt,
            isPublic: dto.isPublic,
            imageList: dto.imageList.map { BoardImageModel(imgOrder: $0.imgOrder, imgUrl: $0.imgUrl) }
        )
    }
    
    // 게시물 이미지 리스트
    func boardImages() -> [BoardImageModel] {
        return selectedBoard?.imageList ?? []
    }
}
