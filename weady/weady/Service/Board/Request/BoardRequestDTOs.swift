//
//  BoardRequestDTOs.swift
//  weady
//
//  Created by 엄민서 on 7/29/25.
//

import Foundation
import UIKit

struct LocalImage: Identifiable, Equatable {
    let id = UUID()
    var image: UIImage
}

struct CreateBoardRequestDTO: Encodable {
    let isPublic: Bool
    let content: String
    let seasonTagId: Int
    let temperatureTagId: Int
    let weatherTagId: Int
    let boardPlaceRequestDtoList: [PlaceDTO]
    let styleIds: [Int]
    let boardBrandRequestDtoList: [BrandDTO]
}

struct UpdateBoardRequestDTO: Encodable {
    let isPublic: Bool
    let content: String
    let seasonTagId: Int
    let temperatureTagId: Int
    let weatherTagId: Int
    let boardPlaceRequestDtoList: [PlaceDTO]
    let styleIds: [Int]
    let boardBrandRequestDtoList: [BrandDTO]   
}

struct ReportBoardRequestDTO: Encodable {
    let reportType: String
    let content: String
}

struct PlaceDTO: Codable {
    let placeName: String
    let placeAddress: String
}

struct BrandDTO: Codable {
    let brand: String
    let product: String
}
