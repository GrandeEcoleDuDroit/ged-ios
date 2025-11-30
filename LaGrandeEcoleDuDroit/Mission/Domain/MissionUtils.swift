import Foundation

struct MissionUtils {
    struct Image {
        static let folderName = "MissionImages"
        
        static func generateFileName(missionId: String) -> String {
            "\(missionId)-mission-image-\(Date().toEpochMilli())"
        }
        
        static func formatUrl(fileName: String?) -> String? {
            var missionImageUrl: String? = nil

            if let fileName {
                let imagePath = folderName + "/" + fileName
                missionImageUrl = UrlUtils.formatOracleBucketUrl(imagePath: imagePath)
            }
            
            return missionImageUrl
        }
        
        static func extractFileNameFromPath(path: String?) -> String? {
            UrlUtils.extractFileNameFromPath(path: path)
        }
        
        static func extractFileNameFromUrl(url: String?) -> String? {
            UrlUtils.extractFileNameFromUrl(url: url)
        }
    }
}
