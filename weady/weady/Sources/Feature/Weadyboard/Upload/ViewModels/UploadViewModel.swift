import Foundation
import Combine

@MainActor
class UploadViewModel: ObservableObject {
    @Published var content: String = ""
    @Published var isPublic: Bool = true
    @Published var includesAd: Bool = false

    @Published var selectedWeatherId: Int?
    @Published var selectedTempId: Int?
    @Published var selectedSeasonId: Int?

    @Published var selectedStyleIds: [Int] = []
    @Published var selectedPlaces: [PostPlace] = []
    @Published var uploadedImages: [PostImage] = []

    var isFormValid: Bool {
        selectedWeatherId != nil && selectedTempId != nil && selectedSeasonId != nil
    }

    func buildRequest() -> PostRequestBody? {
        guard let weatherId = selectedWeatherId,
              let tempId = selectedTempId,
              let seasonId = selectedSeasonId else {
            return nil
        }

        return PostRequestBody(
            isPublic: isPublic,
            content: content,
            imageDtoList: uploadedImages,
            weatherTagId: weatherId,
            temperatureTagId: tempId,
            seasonTagId: seasonId,
            placeDtoList: selectedPlaces,
            styleIdList: selectedStyleIds
        )
    }

    func submitPost() async throws {
        guard let body = buildRequest(),
              let url = URL(string: "https://your-api.com/api/v1/users/now-location") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)

        let (_, response) = try await URLSession.shared.data(for: request)
        print("Post response: \(response)")
    }
}
