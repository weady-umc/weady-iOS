//
//  WeadychiveViewModel.swift
//  weady
//
//  Created by 고석현 on 7/26/25.
//

import SwiftUI
import Foundation
import Moya
import KeychainSwift

@MainActor
final class WeadychiveViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var scrappedCurationItems: [CurationItem] = []
    @Published var scrappedWeadyboardItems: [WeadyboardItem] = []
    @Published var isCurationFetchFailed: Bool = false
    @Published var isWeadyboardFetchFailed: Bool = false
    @Published var isCurationLoaded: Bool = false
    @Published var isWeadyboardLoaded: Bool = false
    @Published private(set) var scrappedBoardIds: Set<Int> = []

    var hasScrappedCurations: Bool {
        scrappedCurationItems.contains { !$0.firstImgUrl.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }
    
    var hasScrappedWeadyboards: Bool {
        scrappedWeadyboardItems.contains {
            !($0.imgUrl ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }
    
    // MARK: - Service
    private let service = WeadychiveService()
    
    // MARK: - Init
    init() {
        //TODO: 실제 API 호출로 변경할 것
         fetchScrappedCurations()
         fetchScrappedBoards()
        
//        //MARK: -  Mock 데이터로 초기화 (테스트용) . 서버 통신 실패 시 대체용 mock 데이터.
//        scrappedCurationItems = (0..<10).map {
//            CurationItem(
//                id: $0,
//                title: "Mock Curation \($0)",
//                firstImgUrl: $0 % 2 == 0 ? "curation1" : "curation2"
//            )
//        }
//
//        scrappedWeadyboardItems = (0..<18).map {
//            WeadyboardItem(
//                id: $0,
//                username: "User \($0)",
//                imgUrl: "weadyboard\(($0 % 7) + 1)",
//                weatherTagId: $0 % 5
//            )
//        }
//        
     
    }
    
    // MARK: - API Calls
    
    /// 사용자별 스크랩한 큐레이션 조회
    func fetchScrappedCurations() {
        service.getScrappedCurationsByUser { [weak self] result in
            DispatchQueue.main.async {
                self?.isCurationLoaded = true
                switch result {
                case .success(let response):
                    print("✅ Scrapped Curations API 성공")
                    self?.scrappedCurationItems = response.curations.map {
                        CurationItem(
                            id: $0.curationId,
                            title: $0.curationTitle,
                            firstImgUrl: $0.firstImgUrl
                        )
                    }
                    self?.isCurationFetchFailed = false
                case .failure(let error):
                    print("❌ Scrapped Curations API 실패: \(error)")
                    self?.isCurationFetchFailed = true
                    self?.scrappedCurationItems = []
                }
            }
        }
    }
    
    /// 사용자별 스크랩한 웨디보드 조회
    func fetchScrappedBoards(size: Int = 10, page: Int = 0) {
        service.getScrappedBoardsByUser(size: size, page: page) { [weak self] result in
            DispatchQueue.main.async {
                self?.isWeadyboardLoaded = true
                switch result {
                case .success(let response):
                    print("✅ Scrapped Boards API 성공")
                    self?.scrappedWeadyboardItems = response.content.map {
                        WeadyboardItem(
                            id: $0.boardId,
                            username: $0.username,
                            imgUrl: $0.imgUrl,
                            weatherTagId: $0.weatherTagId
                        )
                    }
                    // 스크랩 여부 게시물 화면에서 확인하기 위해 추가
                    self?.scrappedBoardIds = Set(response.content.map { Int($0.boardId) })
                    self?.isWeadyboardFetchFailed = false
                case .failure(let error):
                    print("❌ Scrapped Boards API 실패: \(error)")
                    self?.isWeadyboardFetchFailed = true
                    self?.scrappedWeadyboardItems = []
                }
            }
        }
    }
    
  
    
    /// 큐레이션 스크랩 삭제
    func removeCurationScrap(curationId: Int) {
        let dto = ScrapCurationRequestDto(curationId: curationId)
        service.deleteScrapCuration(dto: dto) { result in
            switch result {
            case .success(let response):
                print("✅ 큐레이션 스크랩 삭제 성공: \(response.isScraped)")
                self.fetchScrappedCurations()
            case .failure(let error):
                print("❌ 큐레이션 스크랩 삭제 실패: \(error)")
            }
        }
    }
    
    // MARK: - 웨디보드 스크랩 연결
    /// 현재 스크랩 여부 조회
    func isScrapped(boardId: Int) -> Bool {
        return scrappedBoardIds.contains(boardId)
    }
    
    /// 게시물 스크랩 추가
    func addBoardScrap(boardId: Int) {
        let dto = ScrapBoardRequestDto(boardId: boardId)
        service.postScrapBoard(dto: dto) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    print("✅ 웨디보드 스크랩 성공: \(response.isScraped)")
                    if response.isScraped {
                        self?.scrappedBoardIds.insert(boardId)
                    }
                    self?.fetchScrappedBoards()
                case .failure(let error):
                    print("❌ 웨디보드 스크랩 실패: \(error)")
                }
            }
        }
    }
    
    /// 게시물 스크랩 삭제 ( 웨디보드 게시물 화면에서 )
    func removeBoardScrap(boardId: Int) {
        let dto = ScrapBoardRequestDto(boardId: boardId)
        service.deleteScrapBoard(dto: dto) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.scrappedBoardIds.remove(boardId)
                    self?.fetchScrappedBoards()
                case .failure(let error):
                    print("❌ 웨디보드 스크랩 삭제 실패: \(error)")
                }
            }
        }
    }
    
    /// 게시물 스크랩 토글
    func toggleBoardScrap(boardId: Int) {
        if isScrapped(boardId: boardId) {
            removeBoardScrap(boardId: boardId)
        } else {
            addBoardScrap(boardId: boardId)
        }
    }
    
    // MARK: - 큐레이션 스크랩 삭제
    func deleteCurationItems(with ids: [Int64]) {
        for id in ids {
            let dto = ScrapCurationRequestDto(curationId: Int(id))
            service.deleteScrapCuration(dto: dto) { result in
                switch result {
                case .success(let response):
                    print("✅ 서버 큐레이션 스크랩 삭제 성공: \(response.isScraped)")
                case .failure(let error):
                    print("❌ 서버 큐레이션 스크랩 삭제 실패: \(error.localizedDescription)")
                }
            }
        }
        scrappedCurationItems.removeAll { ids.contains(Int64($0.id)) }
    }
//MARK: -웨디보드 스크랩 삭제
    func deleteWeadyboardItems(with ids: [Int64]) {
        for id in ids {
            let dto = ScrapBoardRequestDto(boardId: Int(id))
            service.deleteScrapBoard(dto: dto) { result in
                switch result {
                case .success(let response):
                    print("✅ 서버 웨디보드 스크랩 삭제 성공: \(response.isScraped)")
                case .failure(let error):
                    print("❌ 서버 웨디보드 스크랩 삭제 실패: \(error.localizedDescription)")
                }
            }
        }
        scrappedWeadyboardItems.removeAll { ids.contains(Int64($0.id)) }
    }
    
    // MARK: - Moya Log Test
    func CurationLogOutput() {
        print("🛠 CurationLogOutput 실행됨")
        let token = KeychainSwift().get("serverAccessToken") ?? "없음"
        print("🔑 accessToken: \(token)")
        print("📡 서버에 getScrappedCurationsByUser 요청 전송 시작")
        service.getScrappedCurationsByUser { result in
            switch result {
            case .success(let response):
                print("📥 응답 수신 성공")
                print("  유저명: \(response.userName)")
                print("  큐레이션 개수: \(response.curations.count)")
                for curation in response.curations {
                    print("   - [\(curation.curationId)] \(curation.curationTitle), URL: \(curation.firstImgUrl)")
                }
            case .failure(let error):
                print("🚨 요청 실패: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Weadyboard Log Test
    func WeadyboardLogOutput(size: Int = 10, page: Int = 0) {
        print("🛠 WeadyboardLogOutput 실행됨 (size: \(size), page: \(page))")
        let token = KeychainSwift().get("serverAccessToken") ?? "없음"
        print("🔑 accessToken: \(token)")
        print("📡 서버에 getScrappedBoardsByUser 요청 전송 시작")
        service.getScrappedBoardsByUser(size: size, page: page) { result in
            switch result {
            case .success(let response):
                print("📥 응답 수신 성공")
                print("  총 개수: \(response.content.count)")
                for board in response.content {
                    print("   - [boardId: \(board.boardId)] user: \(board.username), tag: \(board.weatherTagId), URL: \(board.imgUrl)")
                }
            case .failure(let error):
                print("🚨 요청 실패: \(error.localizedDescription)")
            }
        }
    }
}
