struct UrlUtils {
    static func extractFileNameFromUrl(url: String?) -> String? {
        url?.components(separatedBy: "/").last
    }
    
    static func extractFileNameFromPath(path: String?) -> String? {
        path?.components(separatedBy: "/").last
    }
}
