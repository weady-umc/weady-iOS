import Foundation
import Moya

final class UserService: NetworkManager {
    
    typealias Endpoint = UserEndpoints
    let provider: MoyaProvider<UserEndpoints>
    
    public init(provider: MoyaProvider<UserEndpoints>? = nil) {
        let plugins: [PluginType] = [
            NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))
        ]
        self.provider = provider ?? MoyaProvider<UserEndpoints>(plugins: plugins)
    }
    
    // MARK: - 프로필 수정 (닉네임 + 이미지 URL)
    func updateProfile(name: String, profileImageUrl: String?, completion: @escaping (Result<UpdateUserProfileResponse, Error>) -> Void) {
        let requestDTO = EditProfileRequestDTO(
            profileData: ProfileData(name: name),
            profileImage: profileImageUrl
        )
        
        provider.request(.updateProfile(data: requestDTO)) { result in
            switch result {
            case .success(let response):
                do {
                    let decoded = try JSONDecoder().decode(UpdateUserProfileResponse.self, from: response.data)
                    completion(.success(decoded))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - 마이페이지 조회
    func fetchMyPage(year: Int, month: Int, completion: @escaping (Result<GetMyPageResponse, Error>) -> Void) {
        provider.request(.getMyPage(year: year, month: month)) { result in
            switch result {
            case .success(let response):
                do {
                    let decoded = try JSONDecoder().decode(GetMyPageResponse.self, from: response.data)
                    completion(.success(decoded))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - 특정 날짜 게시물 조회
    func fetchBoard(date: String, isPublic: Bool, completion: @escaping (Result<GetBoardInMyPageResponse, Error>) -> Void) {
        provider.request(.getMyPageBoard(date: date, isPublic: isPublic)) { result in
            switch result {
            case .success(let response):
                do {
                    let decoded = try JSONDecoder().decode(GetBoardInMyPageResponse.self, from: response.data)
                    completion(.success(decoded))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
