import Foundation

@Observable
final class MypageViewModel {
    // MARK: - 상태
    var year: Int
    var month: Int
    var selectedFilter: String = "전체보기"
    
    var profile: MypageProfileModel?
    var calendar: [CalendarThumbnailModel] = []
    
    var selectedDate: String? = nil
    var selectedBoard: MypageBoardDetailModel? = nil
    
    private let userService = UserService()
    
    // MARK: - 초기화
    init() {
        let today = Date()
        let comps = Calendar.current.dateComponents([.year, .month], from: today)
        self.year = comps.year ?? 2025
        self.month = comps.month ?? 8
        
        fetchMypageData()
    }
    
    // MARK: - 필터 적용
    var filterCalendar: [CalendarThumbnailModel] {
        switch selectedFilter {
        case "전체보기": return calendar
        case "공개보기": return calendar.filter { $0.isPublic }
        case "나만보기": return calendar.filter { !$0.isPublic }
        default: return calendar
        }
    }
    
    // MARK: - 프로필 업데이트
    func updateProfile(_ newProfile: MypageProfileModel) {
        self.profile = newProfile
    }
    
    // MARK: - 마이페이지 조회
    func fetchMypageData() {
        userService.fetchMyPage(year: year, month: month) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    self?.mapMyPageResponse(data)
                case .failure(let error):
                    print(">>> 마이페이지 불러오기 실패: \(error)")
                }
            }
        }
    }
    
    // MARK: - 특정 날짜 게시물 조회 (캘린더 카드 클릭)
    func fetchBoard(date: String, isPublic: Bool = true) {
        selectedDate = date
        userService.fetchBoard(date: date, isPublic: isPublic) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    if data.boardId == 0 { // 게시물 없음 (boardId==0)
                        self?.selectedBoard = nil
                        print("해당 날짜의 게시물이 없습니다.")
                    } else {
                        self?.mapBoardResponse(data)
                    }
                case .failure(let error):
                    self?.selectedBoard = nil
                    print("해당 날짜의 게시물이 없습니다.")
                    print(">>> 해당 날짜 게시물 조회 실패: \(error)")
                }
            }
        }
    }
    
    // MARK: - DTO → UI 모델 변환
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
                weatherTagId: $0.weatherTagId,
                isPublic: true // TODO: API에서 isPublic 필드 받아오면 교체
            )
        }
    }
    
    private func mapBoardResponse(_ dto: GetBoardInMyPageResponse) {
        selectedBoard = MypageBoardDetailModel(
            boardId: dto.boardId,
            createdAt: dto.createdAt,
            isPublic: dto.isPublic,
            weatherTagId: dto.weatherTagId,
            imageList: dto.imageList.map { BoardImageModel(imgOrder: $0.imgOrder, imgUrl: $0.imgUrl) }
        )
    }
    
    // MARK: - 게시물 이미지 리스트
    func boardImages() -> [BoardImageModel] {
        return selectedBoard?.imageList ?? []
    }
}
