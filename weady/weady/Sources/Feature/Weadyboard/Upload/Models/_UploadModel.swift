import Foundation

public struct UploadImage: Codable {
    let imgUrl: String
    let imgOrder: Int
}

public struct UploadPlace: Codable {
    let placeName: String
    let placeAddress: String
}

public struct UploadBrand: Codable {
    let brand: String
    let product: String
}

// MARK: - 게시물 작성에 필요한 데이터
public struct UploadModel: Codable {
    let isPublic: Bool                 // 커뮤니티 게시 여부 (공개, 보관)
    let isAdd: Bool                    // 유료 광고 여부
    let content: String                // 내용
    let imageDtoList: [UploadImage]    // 사진 리스트
    let imgCount: Int                  // 사진 개수
    let weatherTagId: Int              // 날씨 태그
    let temperatureTagId: Int          // 기온 태그
    let seasonTagId: Int               // 계절 태그
    let placeDtoList: [UploadPlace]    // 장소 태그 (장소명 + 주소)
    let styleIds: [Int]            // 스타일 태그
    let brandDtoList: [UploadBrand]    // 제품 (브랜드 + 제품명)
}

// MARK: - DTO 변환 (이미지 제외한 postData)
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
            styleIds: self.styleIds,
            boardBrandRequestDtoList: self.brandDtoList.map {
                BrandDTO(brand: $0.brand, product: $0.product)
            }
        )
    }
}
