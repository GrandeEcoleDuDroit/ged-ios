import Foundation

struct MissionUtils {
    static func formatImageFileName(missionId: String) -> String {
        "\(missionId)-mission-image-\(Date().toEpochMilli())"
    }
}
