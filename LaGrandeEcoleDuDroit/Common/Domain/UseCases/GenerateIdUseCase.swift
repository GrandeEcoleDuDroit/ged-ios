import Foundation

class GenerateIdUseCase {
    func execute() -> String {
        let timestamp = Int64(Date().timeIntervalSince1970 * 1000)
        let uniqueID = "\(timestamp)-\(UUID().uuidString)"
        return uniqueID
    }
}
