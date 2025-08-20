import Foundation
import Moya
import UIKit

final class UserService: NetworkManager {
    
    typealias Endpoint = UserEndpoints
    let provider: MoyaProvider<UserEndpoints>
    
    init(provider: MoyaProvider<UserEndpoints>? = nil) {
        let plugins: [PluginType] = [
            NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))
        ]
        self.provider = provider ?? MoyaProvider<UserEndpoints>(plugins: plugins)
    }
    
    // MARK: - 프로필 수정 (닉네임 + 이미지)
    func updateProfile(name: String, profileImage: UIImage?, completion: @escaping (Result<UpdateUserProfileResponse, Error>) -> Void) {
        let requestDTO = EditProfileRequestDTO(
            profileData: .init(name: name),
            profileImage: profileImage
        )
        
        provider.request(.updateProfile(data: requestDTO)) { result in
            switch result {
            case .success(let response):
                do {
                    let decoded = try JSONDecoder().decode(BaseResponse<UpdateUserProfileResponse>.self, from: response.data)
                    completion(.success(decoded.data))
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
                    let decoded = try JSONDecoder().decode(BaseResponse<GetMyPageResponse>.self, from: response.data)
                    completion(.success(decoded.data))
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
                    let decoded = try JSONDecoder().decode(BaseResponse<GetBoardInMyPageResponse>.self, from: response.data)
                    completion(.success(decoded.data))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
