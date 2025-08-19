//
//  WeadyPreferredImageStore.swift
//  weady
//
//  Created by 엄민서 on 8/19/25.
//

import Foundation

/// 게시물 스크랩 시 사용자가 보고 있던 이미지 URL을 기기 로컬에 저장/조회
final class WeadyPreferredImageStore {
    static let shared = WeadyPreferredImageStore()
    private init() {}

    private let key = "weady_preferred_image_url_by_board"

    func set(url: String?, for boardId: Int) {
        var map = (UserDefaults.standard.dictionary(forKey: key) as? [String: String]) ?? [:]
        if let url {
            map["\(boardId)"] = url
        } else {
            map.removeValue(forKey: "\(boardId)")
        }
        UserDefaults.standard.set(map, forKey: key)
    }

    func url(for boardId: Int) -> String? {
        let map = (UserDefaults.standard.dictionary(forKey: key) as? [String: String]) ?? [:]
        return map["\(boardId)"]
    }

    func clear(for boardId: Int) {
        set(url: nil, for: boardId)
    }
}