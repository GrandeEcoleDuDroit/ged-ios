import Foundation

struct MissionUtils {
    private init() {}
    
    struct Image {
        private init() {}
        
        static func generateFileName(missionId: String) -> String {
            "\(missionId)-mission-image-\(Date().toEpochMilli())"
        }
        
        static func getFileName(uri: String?) -> String? {
            uri?.components(separatedBy: "/").last
        }
    }
}
