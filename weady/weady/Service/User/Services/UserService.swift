import Foundation
import Moya
import UIKit

final class UserService: NetworkManager {
    
    typealias Endpoint = UserEndpoints
    let provider: MoyaProvider<UserEndpoints>
    
    private weak var appState: AppState?

    init(provider: MoyaProvider<UserEndpoints>? = nil, appState: AppState? = nil) {
        let plugins: [PluginType] = [
            NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))
        ]
        self.provider = provider ?? MoyaProvider<UserEndpoints>(plugins: plugins)
        self.appState = appState
    }
    
    func attach(appState: AppState) {
        self.appState = appState
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
    
    // 앱 진입 또는 로그인 직후: /users/my-page로 내 userId 확보 및 AppState.currentUser 세팅
    func ensureCurrentUserFromMyPage(completion: @escaping (Result<User, Error>) -> Void) {
        let now = Date()
        let comps = Calendar.current.dateComponents([.year, .month], from: now)
        let year = comps.year ?? 1970
        let month = comps.month ?? 1
        
        fetchMyPage(year: year, month: month) { [weak self] result in
            switch result {
            case .success(let my):
                let user = User(
                    id: my.userId,
                    nickname: my.name,
                    profileImageUrl: my.profileImageUrl,
                    email: self?.appState?.currentUser?.email
                )
                self?.appState?.currentUser = user
                completion(.success(user))
                
            case .failure(let err):
                completion(.failure(err))
            }
        }
    }
}
