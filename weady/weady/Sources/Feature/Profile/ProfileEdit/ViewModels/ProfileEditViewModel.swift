import SwiftUI
import PhotosUI

@Observable
final class ProfileEditViewModel {
    var nickname: String
    var profileImageUrl: String?
    var selectedImage: UIImage?
    
    var isSaving: Bool = false
    var saveError: String?
    
    private let userService = UserService()
    private let mypageViewModel: MypageViewModel
    
    // *기본 이미지 URL (서버에 반영되는 주소)*
    private let defaultImageUrl = "https://cdn.yourserver.com/basic-profile.png"
    
    init(mypageViewModel: MypageViewModel) {
        self.mypageViewModel = mypageViewModel
        self.nickname = mypageViewModel.profile?.name ?? ""
        self.profileImageUrl = mypageViewModel.profile?.profileImageUrl
    }
    
    // MARK: - 프로필 저장
    func saveProfile(completion: @escaping (Bool) -> Void) {
        isSaving = true
        saveError = nil
        
        userService.updateProfile(name: nickname, profileImageUrl: profileImageUrl) { [weak self] result in
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
        // *이미지 서버 업로드는 별도로 구현 필요*
        if let imageData = image.jpegData(compressionQuality: 0.9) {
            self.profileImageUrl = imageData.base64EncodedString()
        }
    }
    
    // MARK: - 기본 이미지 적용
    func setDefaultProfileImage() {
        self.selectedImage = UIImage(named: "basicProfileImg")
        self.profileImageUrl = defaultImageUrl
    }
}
