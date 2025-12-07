import Foundation

class GedConfiguration {
    private init() {}
    
    static let serverUrl: String = (Bundle.main.infoDictionary?["SERVER_URL"] as? String).orEmpty()
    
    static let oracleBucketUrl: String = (Bundle.main.infoDictionary?["ORACLE_BUCKET_URL"] as? String).orEmpty()
}
