struct UrlUtils {
    static func formatOracleBucketUrl(fileName: String?) -> String? {
        guard let fileName = fileName else { return nil }
        return GedConfiguration.oracleBucketUrl + "/" + fileName
    }
    
    static func extractFileName(url: String?) -> String? {
        url?.components(separatedBy: "/").last
    }
}
