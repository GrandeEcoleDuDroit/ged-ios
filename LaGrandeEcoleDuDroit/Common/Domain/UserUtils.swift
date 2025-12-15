import Foundation

struct UserUtils {
    private init() {}
    
    struct Name {
        private init() {}
        
        static func formatName(_ name: String) -> String {
            name.capitalizeFirstLetters()
                .capitalizeFirstLetters(separator: "-")
        }
    }
    
    struct ProfilePicture {
        private init() {}
        
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
