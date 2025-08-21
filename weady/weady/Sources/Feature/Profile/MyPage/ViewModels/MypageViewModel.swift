import Foundation
import SwiftUI

final class MypageViewModel: ObservableObject {
    // MARK: - 상태
    @Published var year: Int
    @Published var month: Int
    @Published var selectedFilter: String = "전체보기" {
        didSet { applyFilter() }
    }
    
    @Published var profile: MypageProfileModel?
    @Published var calendar: [CalendarThumbnailModel] = []
    @Published private(set) var filteredCalendar: [CalendarThumbnailModel] = []
    
    @Published var selectedDate: String? = nil
    @Published var selectedBoards: [MypageBoardDetailModel] = []
    
    private let userService = UserService()
    
    // MARK: - 초기화
    init() {
        let today = Date()
        let comps = Calendar.current.dateComponents([.year, .month], from: today)
        self.year = comps.year ?? 2025
        self.month = comps.month ?? 8
        
        fetchMypageData()
    }
    
    // MARK: - 날짜 포맷
    var dateFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        return df
    }
    
    // MARK: - 선택 게시물 초기화
    func clearSelectedBoards() {
        selectedBoards = []
    }
    
    // MARK: - 필터 적용
    private func applyFilter() {
        switch selectedFilter {
        case "전체보기": filteredCalendar = calendar
        case "공개보기": filteredCalendar = calendar.filter { $0.isPublic }
        case "나만보기": filteredCalendar = calendar.filter { !$0.isPublic }
        default: filteredCalendar = calendar
        }
    }
    
    // MARK: - 프로필 업데이트
    func updateProfile(_ newProfile: MypageProfileModel) {
        self.profile = newProfile
    }
    
    // MARK: - 마이페이지 데이터 조회
    func fetchMypageData() {
        userService.fetchMyPage(year: year, month: month) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    self?.mapMyPageResponse(data)
                    self?.applyFilter()
                case .failure(let error):
                    print(">>> 마이페이지 불러오기 실패: \(error)")
                }
            }
        }
    }
    
    // MARK: - 특정 날짜 게시물 조회
    func fetchBoards(for date: String, completion: (() -> Void)? = nil) {
        selectedDate = date
        selectedBoards = []
        
        let group = DispatchGroup()
        
        // 공유중 게시물
        group.enter()
        userService.fetchBoard(date: date, isPublic: true) { [weak self] result in
            DispatchQueue.main.async {
                if case .success(let data) = result, data.boardId != 0,
                   let board = self?.mapBoardResponse(data) {
                    self?.selectedBoards.append(board)
                }
                group.leave()
            }
        }
        
        // 보관중 게시물
        group.enter()
        userService.fetchBoard(date: date, isPublic: false) { [weak self] result in
            DispatchQueue.main.async {
                if case .success(let data) = result, data.boardId != 0,
                   let board = self?.mapBoardResponse(data) {
                    self?.selectedBoards.append(board)
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            self?.selectedBoards.sort { $0.createdAt > $1.createdAt }
            completion?()
        }
    }
    
    // MARK: - DTO → 모델 매핑
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
                isPublic: $0.isPublic
            )
        }
    }
    
    private func mapBoardResponse(_ dto: GetBoardInMyPageResponse) -> MypageBoardDetailModel {
        MypageBoardDetailModel(
            boardId: dto.boardId,
            createdAt: dto.createdAt,
            isPublic: dto.isPublic,
            weatherTagId: dto.weatherTagId,
            imageList: dto.imageList.map { BoardImageModel(imgOrder: $0.imgOrder, imgUrl: $0.imgUrl) }
        )
    }
    
    func boardImages() -> [BoardImageModel] {
        selectedBoards.first?.imageList ?? []
    }
}
