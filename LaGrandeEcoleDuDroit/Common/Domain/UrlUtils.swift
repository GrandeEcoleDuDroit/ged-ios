struct UrlUtils {
    static func formatOracleBucketUrl(fileName: String?) -> String? {
        guard let fileName = fileName else { return nil }
        return GedConfiguration.oracleBucketUrl + "/" + fileName
    }
    
    static func extractFileNameFromUrl(url: String?) -> String? {
        url?.components(separatedBy: "/").last
    }
    
    static func extractFileNameFromPath(path: String?) -> String? {
        path?.components(separatedBy: "/").last
    }
}
