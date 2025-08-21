//import Foundation
//import Observation
//import UIKit
//
//@Observable
//final class UploadViewModel {
//    // MARK: - Services
//    private let boardService = BoardService()
//    
//    // MARK: - Properties
//    var isAdd: Bool = false //TODO: - 백엔드에서 추가 작업 필요 ('유료광고 포함 토글')
//    var isPublic: Bool = true
//    var content: String = ""
//    var localImages: [LocalImage] = []
//    var uploadedImages: [BoardImageDTO] = []  // 서버 업로드 후 받은 이미지 DTO 리스트
//    
//    var weatherModel: WeatherModel = .empty
//    var fashionModel: FashionModel = FashionModel()
//    var placeModel: PlaceModel = PlaceModel()
//    
//    // MARK: - DTO 생성
//    private func buildRequestBody() -> CreateBoardRequestDTO? {
//        guard let season = weatherModel.season,
//              let tempBand = weatherModel.temperature,
//              let weatherTag = weatherModel.weather.first else {
//            return nil
//        }
//
//        let placeDtoList = placeModel.places.map {
//            PlaceDTO(placeName: $0.placeName, placeAddress: $0.placeAddress)
//        }
//
//        let styleIds = fashionModel.selectedStyles.map { $0.rawValue }
//        let brandDtoList = fashionModel.selectedTags.map { tag in
//            BrandDTO(brand: tag.brandName, product: tag.productName)
//        }
//        
//        return CreateBoardRequestDTO(
//            isPublic: isPublic,
//            content: content,
//            weatherTagId: mapWeatherToId(weatherTag),
//            temperatureTagId: tempBand.id,
//            seasonTagId: mapSeasonToId(season),
//            boardPlaceRequestDtoList: placeDtoList,
//            styleIds: styleIds,
//            boardBrandRequestDtoList: brandDtoList
//        )
//    }
//
//    // MARK: - 매핑 함수 (계절, 날씨태그)
//    private func mapSeasonToId(_ season: SeasonType) -> Int {
//        switch season {
//        case .spring: return 1
//        case .summer: return 2
//        case .autumn: return 3
//        case .winter: return 4
//        }
//    }
//    
//    private func mapWeatherToId(_ weather: WeatherType) -> Int {
//        switch weather {
//        case .sunny: return 1
//        case .cloudy: return 2
//        case .rainy: return 3
//        case .partlyCloudy: return 4
//        case .snowy: return 5
//        case .windy: return 6
//        }
//    }
//    
//    // MARK: - 게시글 업로드
//    func submitPost() async -> Bool {
//        do {
//            guard !localImages.isEmpty else { throw UploadError.invalidData }
//            guard let requestDTO = buildRequestBody() else { throw UploadError.invalidData }
//            
//            let response = try await boardService.createBoard(
//                data: requestDTO,
//                images: localImages.map { $0.image }
//            )
//            
//            uploadedImages = response.imageDtoList.sorted { $0.imgOrder < $1.imgOrder }
//            print("*** 업로드 성공, 이미지 개수: \(uploadedImages.count)")
//            uploadedImages.forEach { imageDTO in
//                print("순서: \(imageDTO.imgOrder), URL: \(imageDTO.imgUrl)")
//            }
//            return true
//        } catch {
//            print(">>> 업로드 실패:", error.localizedDescription)
//            return false
//        }
//    }
//    
//    // MARK: - 업로드 에러
//    enum UploadError: Error, LocalizedError {
//        case invalidData
//        case uploadFailed(reason: String)
//        var errorDescription: String? {
//            switch self {
//            case .invalidData: return "업로드할 데이터가 유효하지 않습니다."
//            case .uploadFailed(let reason): return "업로드에 실패했습니다: \(reason)"
//            }
//        }
//    }
//}


import Foundation
import Observation
import UIKit

@Observable
final class UploadViewModel {
    // MARK: - Services
    var mode: UploadMode = .create
    private let boardService = BoardService()
    
    // MARK: - Properties
    var isAdd: Bool = false //TODO: - 백엔드에서 추가 작업 필요 ('유료광고 포함 토글')
    var isPublic: Bool = true
    var content: String = ""
    var localImages: [LocalImage] = []
    var uploadedImages: [BoardImageDTO] = []  // 서버 업로드 후 받은 이미지 DTO 리스트
    
    var weatherModel: WeatherModel = .empty
    var fashionModel: FashionModel = FashionModel()
    var placeModel: PlaceModel = PlaceModel()
    
    // MARK: - DTO 생성 (원형 유지)
    private func buildRequestBody() -> CreateBoardRequestDTO? {
        guard let season = weatherModel.season,
              let tempBand = weatherModel.temperature,
              let weatherTag = weatherModel.weather.first else {
            return nil
        }

        let placeDtoList = placeModel.places.map {
            PlaceDTO(placeName: $0.placeName, placeAddress: $0.placeAddress)
        }

        let styleIds = fashionModel.selectedStyles.map { $0.rawValue }
        let brandDtoList = fashionModel.selectedTags.map { tag in
            BrandDTO(brand: tag.brandName, product: tag.productName)
        }
        
        return CreateBoardRequestDTO(
            isPublic: isPublic,
            content: content,
            seasonTagId: mapSeasonToId(season),
            temperatureTagId: tempBand.id,
            weatherTagId: mapWeatherToId(weatherTag),
            boardPlaceRequestDtoList: placeDtoList,
            styleIds: styleIds,
            boardBrandRequestDtoList: brandDtoList
        )
    }

    // MARK: - 매핑 함수 (계절, 날씨태그)
    private func mapSeasonToId(_ season: SeasonType) -> Int {
        switch season {
        case .spring: return 1
        case .summer: return 2
        case .autumn: return 3
        case .winter: return 4
        }
    }
    
    private func mapWeatherToId(_ weather: WeatherType) -> Int {
        switch weather {
        case .sunny: return 1
        case .cloudy: return 2
        case .rainy: return 3
        case .partlyCloudy: return 4
        case .snowy: return 5
        case .windy: return 6
        }
    }
    
    // MARK: - 게시글 업로드/수정 (원형 흐름 최대한 유지)
    func submitPost() async -> Bool {
        switch mode {
        case .create:
            let upload = UploadModel(
                isPublic: self.isPublic,
                isAdd: self.isAdd,
                content: self.content,
                imageDtoList: [],
                imgCount: localImages.count,
                weatherTagId: mapWeatherToId(weatherModel.weather.first ?? .sunny),
                temperatureTagId: weatherModel.temperature?.id ?? 0,
                seasonTagId: mapSeasonToId(weatherModel.season ?? .spring),
                placeDtoList: placeModel.places.map {
                    UploadPlace(placeName: $0.placeName, placeAddress: $0.placeAddress)
                },
                styleIds: fashionModel.selectedStyles.map { $0.rawValue },
                brandDtoList: fashionModel.selectedTags.map {
                    UploadBrand(brand: $0.brandName, product: $0.productName)
                }
            )
            let dto = upload.toCreateBoardRequestDTO

            do {
                _ = try await boardService.createBoard(
                    data: dto,
                    images: localImages.map { $0.image }
                )
                return true
            } catch {
                print("❌ create 실패: \(error)")
                return false
            }

        case .edit(let post):
            let dto = UpdateBoardRequestDTO(
                isPublic: self.isPublic,
                content: self.content,
                seasonTagId: post.seasonTagId,          // 스냅샷 유지(타입 충돌 방지)
                temperatureTagId: post.temperatureTagId, // 스냅샷 유지
                weatherTagId: post.weatherTagId,         // 스냅샷 유지
                boardPlaceRequestDtoList: placeModel.places.isEmpty
                    ? post.placeDtoList
                    : placeModel.places.map { PlaceDTO(placeName: $0.placeName, placeAddress: $0.placeAddress) },
                styleIds: post.styleIdList, // 현재 구조상 안전하게 스냅샷 유지
                boardBrandRequestDtoList: fashionModel.selectedTags.isEmpty
                    ? post.brandDtoList
                    : fashionModel.selectedTags.map { BrandDTO(brand: $0.brandName, product: $0.productName) }
            )

            return await withCheckedContinuation { continuation in
                boardService.updateBoard(boardId: post.boardId, data: dto) { result in
                    switch result {
                    case .success:
                        continuation.resume(returning: true)
                    case .failure(let err):
                        print("❌ update 실패: \(err)")
                        continuation.resume(returning: false)
                    }
                }
            }
        }
    }
}
