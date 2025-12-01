import Foundation

struct MissionUtils {
    struct ImageFile {
        private static let folderName = "MissionImages"
        
        static func generateFileName(missionId: String) -> String {
            "\(missionId)-mission-image-\(Date().toEpochMilli())"
        }
        
        static func relativePath(fileName: String) -> String {
            "\(folderName)/\(fileName)"
        }
    }
}
