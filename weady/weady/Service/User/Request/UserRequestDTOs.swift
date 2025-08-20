import Foundation
import UIKit

struct EditProfileRequestDTO {
    let profileData: ProfileData
    let profileImage: UIImage?
    
    struct ProfileData: Encodable {
        let name: String
    }
}
