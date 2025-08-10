import Foundation

public struct UploadImage: Codable {
    let imgUrl: String
    let imgOrder: Int
}

public struct UploadPlace: Codable {
    let placeName: String
    let placeAddress: String
}

//MARK: - 게시물 작성에 필요한 데이터
public struct UploadModel: Codable {
    let isPublic: Bool               // 커뮤니티 게시 여부 (공개, 보관)
    let content: String              // 내용
    let imageDtoList: [UploadImage]  // 사진
    let weatherTagId: Int            // 날씨 태그
    let temperatureTagId: Int        // 기온 태그
    let seasonTagId: Int             // 계절 태그
    let placeDtoList: [UploadPlace]  // 장소 태그 (장소명, 주소)
    let styleIdList: [Int]           // 패션 태그 (브랜드명, 제품명)
}

extension UploadModel {
    var toCreateBoardRequestDTO: CreateBoardRequestDTO {
        CreateBoardRequestDTO(
            isPublic: self.isPublic,
            content: self.content,
            weatherTagId: self.weatherTagId,
            temperatureTagId: self.temperatureTagId,
            seasonTagId: self.seasonTagId,
            boardPlaceRequestDtoList: self.placeDtoList.map {
                PlaceDTO(placeName: $0.placeName, placeAddress: $0.placeAddress)
            },
            styleIds: self.styleIdList
        )
    }
}
