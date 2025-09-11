struct UrlUtils {
    static func formatOracleBucketUrl(fileName: String?) -> String? {
        guard let fileName = fileName else { return nil }
        return "https://objectstorage.eu-paris-1.oraclecloud.com/n/ax5bfuffglob/b/bucket-gedoise/o/\(fileName)"
    }
    
    static func extractFileName(url: String?) -> String? {
        url?.components(separatedBy: "/").last
    }
}
