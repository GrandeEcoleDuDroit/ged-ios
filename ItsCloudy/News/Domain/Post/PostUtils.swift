import Foundation

struct PostUtils {
    private init () {}
    
    struct Image {
        private init () {}
        
        static func generateFileName(postId: String) -> String {
            "\(postId)-post-image-\(Date().toEpochMilli())"
        }
        
        static func extractFileName(uri: String?) -> String? {
            uri?.components(separatedBy: "/").last
        }
    }
}
