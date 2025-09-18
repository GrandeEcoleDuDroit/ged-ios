import Foundation

class GedConfiguration {
    private init() {}
    
    static let serverUrl: String = (Bundle.main.infoDictionary?["SERVER_URL"] as? String).toString()
}
