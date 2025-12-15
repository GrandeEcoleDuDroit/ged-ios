extension UserUtils.ProfilePicture {
    static func url(fileName: String?) -> String? {
        if let fileName {
            "\(GedConfiguration.oracleBucketUrl)/\(relativePath(fileName: fileName))"
        } else {
            nil
        }
    }
}
