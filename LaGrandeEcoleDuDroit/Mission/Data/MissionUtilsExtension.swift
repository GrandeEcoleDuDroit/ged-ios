extension MissionUtils.Image {
    private static let folderName = "MissionImages"

    static func getUrl(fileName: String?) -> String? {
        return if let fileName {
            "\(GedConfiguration.oracleBucketUrl)/\(folderName)/\(fileName)"
        } else {
            nil
        }
    }
    
    static func getRelativePath(fileName: String) -> String {
        "\(folderName)/\(fileName)"
    }
}
