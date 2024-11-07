import Foundation

private let serverUrl = "http://89.168.52.45:3000"

extension URL {
    static func oracleUrl(endpoint: String) -> URL? {
        URL(string: endpoint, relativeTo: URL(string: serverUrl))
    }
}
