struct UrlUtils {
    static func formatProfilePictureUrl(fileName: String?) -> String? {
        guard let fileName = fileName else { return nil }
        return "https://objectstorage.eu-paris-1.oraclecloud.com/n/ax5bfuffglob/b/bucket-gedoise/o/\(fileName)"
    }
    
    static func getFileNameFromUrl(url: String?) -> String? {
        url?.components(separatedBy: "/").last
    }
}
