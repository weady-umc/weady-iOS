//
//  BoardRequesetDTOs.swift
//  weady
//
//  Created by 엄민서 on 7/29/25.
//

import Foundation

struct CreateBoardRequestDTO: Encodable {
    let isPublic: Bool
    let content: String
    let weatherTagId: Int
    let temperatureTagId: Int
    let seasonTagId: Int
    let boardPlaceRequestDtoList: [PlaceDTO]
    let styleIds: [Int]
}

struct UpdateBoardRequestDTO: Encodable {
    let isPublic: Bool
    let content: String
    let weatherTagId: Int
    let temperatureTagId: Int
    let seasonTagId: Int
    let boardPlaceRequestDtoList: [PlaceDTO]
    let styleIds: [Int]
}

struct ReportBoardRequestDTO: Encodable {
    let reportType: String
    let content: String
}

struct PlaceDTO: Codable {
    let placeName: String
    let placeAddress: String
}
