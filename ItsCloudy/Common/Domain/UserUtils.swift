import Foundation

struct UserUtils {
    private init() {}
    
    struct Name {
        private init() {}
        
        static func formatName(_ name: String) -> String {
            name.capitalizeWords()
        }
    }
    
    struct ProfilePicture {
        private init() {}
                
        static func generateFileName(userId: String) -> String {
            "\(userId)-profile-picture-\(Date().toEpochMilli())"
        }
        
        static func getFileName(url: String?) -> String? {
            url?.components(separatedBy: "/").last
        }
    }
}
