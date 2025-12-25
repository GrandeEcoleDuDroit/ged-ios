extension UserUtils.ProfilePicture {
    static func getUrl(fileName: String?) -> String? {
        let folderName = "UserProfilePictures"
        return if let fileName {
            "\(GedConfiguration.oracleBucketUrl)/\(folderName)/\(fileName)"
        } else {
            nil
        }
    }
}
