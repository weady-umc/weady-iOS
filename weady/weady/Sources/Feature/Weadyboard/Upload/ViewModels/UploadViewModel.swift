import Foundation
import Observation
import UIKit

//MARK: - UI 용 이미지 모델
struct LocalImage: Identifiable, Equatable {
    let id = UUID()
    var image: UIImage
}

@Observable
final class UploadViewModel {
    var content: String = ""
    var isPublic: Bool = true
    var includesAd: Bool = false

    var localImages: [LocalImage] = []              // UI용 이미지
    private var uploadedImageURLs: [String] = []    // 서버 업로드 후 URL 저장

    // MARK: - 날씨, 패션, 장소 추가 화면의 모델 데이터 통합
    var weatherModel: WeatherModel = .empty
    var fashionModel: FashionModel = FashionModel()
    var placeModel: PlaceModel = PlaceModel()

    // MARK: - API 업로드용 데이터 변환
    func buildRequestBody() -> UploadData? {
        guard let season = weatherModel.season,
              let tempBand = weatherModel.temperature,
              let weatherTag = weatherModel.weather.first else {
            return nil
        }

        let imageDtoList: [UploadImage] = uploadedImageURLs.enumerated().map { index, url in
            UploadImage(imgUrl: url, imgOrder: index)
        }

        // 장소 정보 변환
        let placeDtos: [UploadPlace] = placeModel.places.map {
            UploadPlace(placeName: $0.placeName, placeAddress: $0.placeAddress)
        }

        // 스타일 ID만 추출
        let styleIds: [Int] = fashionModel.selectedStyles.compactMap { Int($0) }

        return UploadData(
            isPublic: isPublic,
            content: content,
            imageDtoList: imageDtoList,
            weatherTagId: mapWeatherToId(weatherTag),
            temperatureTagId: tempBand.id,
            seasonTagId: mapSeasonToId(season),
            placeDtoList: placeDtos,
            styleIdList: styleIds
        )
    }
    
    // MARK: - 날씨/계절 태그 → ID 매핑
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
    
    // MARK: - 게시물 업로드
    func submitPost() async throws {
        // 1. 이미지 먼저 업로드 (이 부분은 mock)
        uploadedImageURLs = try await uploadImages(localImages)

        // 2. 최종 업로드용 데이터 생성
        guard let requestData = buildRequestBody(),
              let url = URL(string: "https://your-api.com/api/v1/posts") else {
            print("업로드 데이터 누락")
            return
        }

        // 디버깅용 출력
        print("<업로드 데이터 확인>")
        print("isPublic:", requestData.isPublic)
        print("content:", requestData.content)
        print("imageDtoList:", requestData.imageDtoList)
        print("seasonTagId:", requestData.seasonTagId)
        print("temperatureTagId:", requestData.temperatureTagId)
        print("weatherTagId:", requestData.weatherTagId)
        print("placeDtoList:", requestData.placeDtoList)
        print("styleIdList:", requestData.styleIdList)

        // 3. POST 요청 전송
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(requestData)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let res = response as? HTTPURLResponse,
              (200..<300).contains(res.statusCode) else {
            throw URLError(.badServerResponse)
        }

        print("업로드 성공: \(data)")
    }

    // MARK: - 이미지 업로드
    private func uploadImages(_ images: [LocalImage]) async throws -> [String] {
        //TODO: - 실제 업로드 API 연동 시, 이 부분 수정 (예시로 임시 URL 반환)
        return images.map { _ in
            "https://cdn.example.com/image/\(UUID().uuidString).jpg"
        }
    }
}
