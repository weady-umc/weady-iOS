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

    var selectedStyleIds: [Int] = []
    var selectedPlaces: [UploadPlace] = []

    // MARK: - 날씨 모델 (필수 필드)
    var weatherTagId: Int?
    var temperatureTagId: Int?
    var seasonTagId: Int?

    var isFormValid: Bool {
        weatherTagId != nil &&
        temperatureTagId != nil &&
        seasonTagId != nil
    }

    // MARK: - API 업로드용 변환
    func buildRequestBody() -> UploadData? {
        guard let weather = weatherTagId,
              let temp = temperatureTagId,
              let season = seasonTagId else {
            return nil
        }

        let imageDtoList: [UploadImage] = uploadedImageURLs.enumerated().map { index, url in
            UploadImage(imgUrl: url, imgOrder: index)
        }

        return UploadData(
            isPublic: isPublic,
            content: content,
            imageDtoList: imageDtoList,
            weatherTagId: weather,
            temperatureTagId: temp,
            seasonTagId: season,
            placeDtoList: selectedPlaces,
            styleIdList: selectedStyleIds
        )
    }

    // MARK: - 게시물 업로드
    func submitPost() async throws {
        // TODO: - 이미지 먼저 업로드 후 URL 획득 (추후 이미지 업로드 API 연동)
        uploadedImageURLs = try await uploadImages(localImages)

        guard let requestData = buildRequestBody(),
              let url = URL(string: "https://your-api.com/api/v1/posts") else {
            print("업로드 데이터 누락")
            return
        }

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
