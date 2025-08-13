import Foundation
import Observation
import UIKit

struct LocalImage: Identifiable, Equatable {
    let id = UUID()
    var image: UIImage
}

@Observable
final class UploadViewModel {
    // MARK: - Services
    private let boardService = BoardService()
    
    // MARK: - Properties
    var isPublic: Bool = true
    var isAdd: Bool = false
    var content: String = ""
    var localImages: [LocalImage] = []
    var uploadedImageURLs: [String] = []  // 서버 업로드 후 받은 이미지 URL 리스트
    
    var weatherModel: WeatherModel = .empty
    var fashionModel: FashionModel = FashionModel()
    var placeModel: PlaceModel = PlaceModel()
    
    // MARK: - DTO 생성
    private func buildRequestBody() -> UploadModel? {
        guard let season = weatherModel.season,
              let tempBand = weatherModel.temperature,
              let weatherTag = weatherModel.weather.first else {
            return nil
        }

        let imageDtoList = uploadedImageURLs.enumerated().map { index, url in
            UploadImage(imgUrl: url, imgOrder: index + 1)
        }

        let placeDtoList = placeModel.places.map {
            UploadPlace(placeName: $0.placeName, placeAddress: $0.placeAddress)
        }

        let styleIdList = fashionModel.selectedStyles.map { $0.rawValue }
        let brandDtoList = fashionModel.selectedTags.map { tag in
                UploadBrand(brand: tag.brandName, product: tag.productName)
            }
        
        return UploadModel(
            isPublic: isPublic,
            isAdd: isAdd,
            content: content,
            imageDtoList: imageDtoList,
            imgCount: uploadedImageURLs.count,
            weatherTagId: mapWeatherToId(weatherTag),
            temperatureTagId: tempBand.id,
            seasonTagId: mapSeasonToId(season),
            placeDtoList: placeDtoList,
            styleIds: styleIdList,
            brandDtoList: brandDtoList
        )
    }

    // MARK: - 매핑 함수
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
    
    // MARK: - 업로드 함수 (async/await + completion wrapper)
    func submitPost() async -> Bool {
        do {
            // 1. 이미지 업로드 후 URL 획득
            uploadedImageURLs = try await uploadImages(localImages)

            // 2. DTO 생성
            guard let uploadModel = buildRequestBody() else {
                throw UploadError.invalidData
            }

            let requestDTO = uploadModel.toCreateBoardRequestDTO

            // 3. API 호출 (completion -> async 래핑)
            try await withCheckedThrowingContinuation { continuation in
                boardService.createBoard(data: requestDTO) { result in
                    switch result {
                    case .success:
                        continuation.resume()
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
            }
            print("!!!!! 업로드 성공")
            return true
        } catch {
            print("***** 업로드 실패:", error.localizedDescription)
            return false
        }
    }
    
    // MARK: - 이미지 업로드 (테스트용)
    private func uploadImages(_ images: [LocalImage]) async throws -> [String] {
        // TODO: 실제 업로드 API 연결 (테스트용 임시 URL 반환)
        return images.map { _ in
            "https://cdn.example.com/image/\(UUID().uuidString).jpg"
        }
    }
    
    // MARK: - 업로드 에러 세부설명
    enum UploadError: Error, LocalizedError {
        case invalidData
        case uploadFailed(reason: String)
        
        var errorDescription: String? {
            switch self {
            case .invalidData:
                return "업로드할 데이터가 유효하지 않습니다."
            case .uploadFailed(let reason):
                return "업로드에 실패했습니다: \(reason)"
            }
        }
    }
}
