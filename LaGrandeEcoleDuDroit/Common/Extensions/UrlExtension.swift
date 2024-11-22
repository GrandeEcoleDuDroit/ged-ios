import Foundation

extension URL {
    static func oracleUrl(endpoint: String) -> URL? {
        URL(string: endpoint, relativeTo: URL(string: GedConfig.serverUrl))
    }
}
