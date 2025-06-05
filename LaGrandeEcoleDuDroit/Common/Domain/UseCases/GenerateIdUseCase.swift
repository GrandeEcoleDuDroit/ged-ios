import Foundation

class GenerateIdUseCase {
    static func stringId() -> String {
        let timestamp = Int64(Date().timeIntervalSince1970 * 1000)
        let uniqueID = "\(timestamp)-\(UUID().uuidString)"
        return uniqueID
    }
    
    static func intId() -> Int {
        let uuid = UUID().uuid
        let raw = withUnsafeBytes(of: uuid) { ptr in
            ptr.load(as: UInt64.self)
        }
        return Int(raw % UInt64(Int.max))
    }
}
