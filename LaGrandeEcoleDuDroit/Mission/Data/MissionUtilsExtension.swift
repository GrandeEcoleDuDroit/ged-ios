extension MissionUtils.ImageFile {
    static func url(fileName: String?) -> String? {
        if let fileName {
            "\(GedConfiguration.oracleBucketUrl)/\(relativePath(fileName: fileName))"
        } else {
            nil
        }
    }
    
    static func extractFileNameFromPath(path: String?) -> String? {
        path?.components(separatedBy: "/").last
    }
}
