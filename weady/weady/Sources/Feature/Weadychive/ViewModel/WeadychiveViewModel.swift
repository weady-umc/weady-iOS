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
    
    var hasScrappedCurations: Bool {
        !scrappedCurationItems.isEmpty
    }
    
    var hasScrappedWeadyboards: Bool {
        !scrappedWeadyboardItems.isEmpty
    }
    
    // MARK: - Service
    private let service = WeadychiveService()
    
    // MARK: - Init
    init() {
        // 앱 시작 시 더미 데이터 대신 서버 데이터 불러오기
        fetchScrappedCurations()
        fetchScrappedBoards()
        
        // Moya 로그 테스트
        testMoyaLogOutput()
    }
    
    // MARK: - API Calls
    
    /// 사용자별 스크랩한 큐레이션 조회
    func fetchScrappedCurations() {
        service.getScrappedCurationsByUser { [weak self] result in
            DispatchQueue.main.async {
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
                case .failure(let error):
                    print("❌ Scrapped Curations API 실패: \(error)")
                }
            }
        }
    }
    
    /// 사용자별 스크랩한 웨디보드 조회
    func fetchScrappedBoards(size: Int = 18, page: Int = 0) {
        service.getScrappedBoardsByUser(size: size, page: page) { [weak self] result in
            DispatchQueue.main.async {
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
                case .failure(let error):
                    print("❌ Scrapped Boards API 실패: \(error)")
                }
            }
        }
    }
    
    /// 큐레이션 스크랩 추가
    func addCurationScrap(curationId: Int) {
        let dto = ScrapCurationRequestDto(curationId: curationId)
        service.postScrapCuration(dto: dto) { result in
            switch result {
            case .success(let response):
                print("✅ 큐레이션 스크랩 성공: \(response.isScraped)")
                self.fetchScrappedCurations()
            case .failure(let error):
                print("❌ 큐레이션 스크랩 실패: \(error)")
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
    
    /// 게시물 스크랩 추가
    func addBoardScrap(boardId: Int) {
        let dto = ScrapBoardRequestDto(boardId: boardId)
        service.postScrapBoard(dto: dto) { result in
            switch result {
            case .success(let response):
                print("✅ 웨디보드 스크랩 성공: \(response.isScraped)")
                self.fetchScrappedBoards()
            case .failure(let error):
                print("❌ 웨디보드 스크랩 실패: \(error)")
            }
        }
    }
    
    /// 게시물 스크랩 삭제
    func removeBoardScrap(boardId: Int) {
        let dto = ScrapBoardRequestDto(boardId: boardId)
        service.deleteScrapBoard(dto: dto) { result in
            switch result {
            case .success(let response):
                print("✅ 웨디보드 스크랩 삭제 성공: \(response.isScraped)")
                self.fetchScrappedBoards()
            case .failure(let error):
                print("❌ 웨디보드 스크랩 삭제 실패: \(error)")
            }
        }
    }
    
    // MARK: - 로컬 데이터 삭제 (뷰에서 사용)
    func deleteCurationItems(with ids: [Int64]) {
        scrappedCurationItems.removeAll { ids.contains(Int64($0.id)) }
    }
    
    func deleteWeadyboardItems(with ids: [Int64]) {
        scrappedWeadyboardItems.removeAll { ids.contains(Int64($0.id)) }
    }
    
    // MARK: - Moya Log Test
    func testMoyaLogOutput() {
        print("🛠 testMoyaLogOutput 실행됨")
        let token = KeychainSwift().get("serverAccessToken") ?? "없음"
        print("🔑 accessToken: \(token)")
        
        service.getScrappedCurationsByUser { result in
            switch result {
            case .success(let response):
                print("📥 응답 수신: \(response)")
            case .failure(let error):
                print("🚨 요청 실패: \(error)")
            }
        }
    }
}
