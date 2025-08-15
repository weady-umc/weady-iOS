import Foundation

struct EditProfileRequestDTO: Encodable {
    let profileData: ProfileData
    let profileImage: String? // URL or Base64
}

struct ProfileData: Encodable {
    let name: String
}
