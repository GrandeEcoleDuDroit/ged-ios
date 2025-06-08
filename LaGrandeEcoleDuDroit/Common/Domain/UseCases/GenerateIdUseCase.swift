import Foundation

class GenerateIdUseCase {
    static func stringId() -> String {
        let timestamp = Int64(Date().timeIntervalSince1970 * 1000)
        let uniqueID = "\(timestamp)-\(UUID().uuidString)"
        return uniqueID
    }
    
    static func intId() -> Int64 {
        let uuid = UUID().uuid
        let raw = withUnsafeBytes(of: uuid) { ptr in
            ptr.load(as: Int64.self)
        }
        return abs(raw)
    }
}
