import Foundation

#if DEBUG
private let serverUrl = "" // Set your local server url here
#else
private let serverUrl = "http:89.168.52.45//:3000"
#endif

extension URL {
    static func oracleUrl(endpoint: String) -> URL? {
        URL(string: endpoint, relativeTo: URL(string: serverUrl))
    }
}
