import Foundation

struct UserUtils {
    struct ProfilePictureFile {
        private static let folderName = "UserProfilePictures"
        
        static func generateFileName(userId: String) -> String {
            "\(userId)-profile-picture-\(Date().toEpochMilli())"
        }
        
        static func relativePath(fileName: String) -> String {
            "\(folderName)/\(fileName)"
        }
        
        static func getFileName(url: String?) -> String? {
            url?.components(separatedBy: "/").last
        }
    }
}
