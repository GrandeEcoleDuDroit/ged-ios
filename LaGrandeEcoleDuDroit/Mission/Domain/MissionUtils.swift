import Foundation

struct MissionUtils {
    private init() {}
    
    struct ImageFile {
        private init() {}
        
        private static let folderName = "MissionImages"
        
        static func generateFileName(missionId: String) -> String {
            "\(missionId)-mission-image-\(Date().toEpochMilli())"
        }
        
        static func relativePath(fileName: String) -> String {
            "\(folderName)/\(fileName)"
        }
        
        static func extractFileNameFromUrl(url: String?) -> String? {
            url?.components(separatedBy: "/").last
        }
        
        static func getImagePathFromUrl(url: String?) -> String? {
            if let fileName = extractFileNameFromUrl(url: url) {
                relativePath(fileName: fileName)
            } else {
                nil
            }
        }
    }
}
