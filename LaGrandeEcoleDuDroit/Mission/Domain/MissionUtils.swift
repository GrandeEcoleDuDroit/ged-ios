import Foundation

struct MissionUtils {
    static let folderName = "MissionImages"
    
    static func formatImageFileName(missionId: String) -> String {
        "\(missionId)-mission-image-\(Date().toEpochMilli())"
    }
}
