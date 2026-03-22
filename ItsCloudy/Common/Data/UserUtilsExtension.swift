extension UserUtils.ProfilePicture {
    private static let folderName = "UserProfilePictures"

    static func formatUrl(fileName: String?) -> String? {
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
