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
    }
}
