extension MissionUtils.ImageFile {
    static func url(fileName: String?) -> String? {
        if let fileName {
            "\(GedConfiguration.oracleBucketUrl)/\(relativePath(fileName: fileName))"
        } else {
            nil
        }
    }
    
    static func getFileNameFromPath(path: String?) -> String? {
        path?.components(separatedBy: "/").last
    }
    
    static func getFileNameFromUrl(url: String?) -> String? {
        url?.components(separatedBy: "/").last
    }
}
