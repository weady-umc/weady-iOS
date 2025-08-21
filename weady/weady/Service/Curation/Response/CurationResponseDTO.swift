import Foundation

//큐레이션

// MARK: - ApiResponseCurationByCurationIdResponseDto
struct ApiResponseCurationByCurationIdResponseDto: Codable {
    let code: Int
    let message: String
    let data: CurationByCurationIdResponseDto

    enum CodingKeys: String, CodingKey {
        case code
        case message
        case data
    }
}

// MARK: - CurationByCurationIdResponseDto
struct CurationByCurationIdResponseDto: Codable {
    let curationId: Int64
    let curationTitle: String
    let imgs: [ImgDto]

    enum CodingKeys: String, CodingKey {
        case curationId
        case curationTitle
        case imgs
    }
}

// MARK: - ImgDto
struct ImgDto: Codable {
    let imgUrl: String
    let imgOrder: Int
    let imgAddress: String //이미지 주소
    //let imgAddress: String

    enum CodingKeys: String, CodingKey {
        case imgUrl
        case imgOrder
        case imgAddress
    }
}

struct curationDTO: Codable {
    let curationId: Int64
    let curationTitle: String
    let backgroundImgUrl: String
}

// MARK: - ApiResponseCurationByLocationResponseDto
struct ApiResponseCurationByLocationResponseDto: Codable {
    let code: Int
    let message: String
    let data: CurationByLocationResponseDto

    enum CodingKeys: String, CodingKey {
        case code
        case message
        case data
    }
}

// MARK: - CurationByLocationResponseDto
struct CurationByLocationResponseDto: Codable {
    let locationId: Int64
    let locationName: String
    let season: String
    let weather: String
    let curations: [curationDTO] //웨디카이브 DTO

    enum CodingKeys: String, CodingKey {
        case locationId
        case locationName
        case season
        case weather
        case curations
    }
}



// MARK: - ApiResponseListCurationCategoryResponseDto
struct ApiResponseListCurationCategoryResponseDto: Codable {
    let code: Int
    let message: String
    let data: [CurationCategoryResponseDto]

    enum CodingKeys: String, CodingKey {
        case code
        case message
        case data
    }
}

// MARK: - CurationCategoryResponseDto
struct CurationCategoryResponseDto: Codable {
    let curationCategoryId: Int64
    let locationName: String

    enum CodingKeys: String, CodingKey {
        case curationCategoryId
        case locationName
    }
}

// MARK: - ApiResponseGetUserDefaultLocationResponse
struct ApiResponseGetUserDefaultLocationResponse: Codable {
    let code: Int
    let message: String
    let data: GetUserDefaultLocationResponse

    enum CodingKeys: String, CodingKey {
        case code
        case message
        case data
    }
}

// MARK: - GetUserDefaultLocationResponse
struct GetUserDefaultLocationResponse: Codable {
    let defaultLocationId: Int64
    let bCode: String
    let address1: String
    let address2: String
    let address3: String
    let address4: String

    enum CodingKeys: String, CodingKey {
        case defaultLocationId
        case bCode
        case address1
        case address2
        case address3
        case address4
    }
}
