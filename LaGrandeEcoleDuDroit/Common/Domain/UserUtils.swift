import Foundation

struct UserUtils {
    struct ProfilePicture {
        static let folderName = "UserProfilePictures"
        
        static func generateFileName(userId: String) -> String {
            "\(userId)-profile-picture-\(Date().toEpochMilli())"
        }
        
        static func formatUrl(fileName: String?) -> String? {
            var profilePictureUrl: String? = nil

            if let fileName {
                let imagePath = folderName + "/" + fileName
                profilePictureUrl = UrlUtils.formatOracleBucketUrl(imagePath: imagePath)
            }
            
            return profilePictureUrl
        }
        
        static func extractFileName(url: String?) -> String? {
            UrlUtils.extractFileNameFromUrl(url: url)
        }
    }
}
