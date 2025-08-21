import SwiftUI
import PhotosUI

@Observable
final class ProfileEditViewModel {
    // MARK: - Properties
    var nickname: String
    var profileImageUrl: String?
    var selectedImage: UIImage?
    
    var isSaving: Bool = false
    var saveError: String?
    
    private let userService = UserService()
    private let mypageViewModel: MypageViewModel
    
    private let defaultImageUrl = "https://cdn.yourserver.com/basic-profile.png"
    
    // MARK: - Init
    init(mypageViewModel: MypageViewModel) {
        self.mypageViewModel = mypageViewModel
        self.nickname = mypageViewModel.profile?.name ?? ""
        self.profileImageUrl = mypageViewModel.profile?.profileImageUrl
    }
    
    // MARK: - 프로필 저장 (닉네임 + 이미지)
    func saveProfile(completion: @escaping (Bool) -> Void) {
        isSaving = true
        saveError = nil
        
        userService.updateProfile(name: nickname, profileImage: selectedImage) { [weak self] result in
            DispatchQueue.main.async {
                self?.isSaving = false
                switch result {
                case .success(let response):
                    let updatedProfile = MypageProfileModel(
                        id: response.userId,
                        name: response.name,
                        profileImageUrl: response.profileImageUrl
                    )
                    self?.mypageViewModel.updateProfile(updatedProfile)
                    
                    UserDefaults.standard.set(response.name.trimmingCharacters(in: .whitespacesAndNewlines), forKey: "nickname")
                    if let url = response.profileImageUrl {
                        UserDefaults.standard.set(url, forKey: "profileImageUrl") // (선택) 이미지도 전역 반영할 때
                    }
                    
                    completion(true)
                case .failure(let error):
                    self?.saveError = error.localizedDescription
                    completion(false)
                }
            }
        }
    }
    
    // MARK: - 이미지 선택 (앨범)
    func setProfileImage(_ image: UIImage) {
        self.selectedImage = image
        self.profileImageUrl = nil // Base64 제거
    }
    
    // MARK: - 기본 이미지 적용
    func setDefaultProfileImage() {
        self.selectedImage = nil
        self.profileImageUrl = defaultImageUrl
    }
}
