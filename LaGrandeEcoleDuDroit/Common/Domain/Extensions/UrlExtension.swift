import Foundation

extension URL {
    static func oracleUrl(path: String) -> URL? {
        URL(string: path, relativeTo: URL(string: GedConfiguration.serverUrl))
    }
}
