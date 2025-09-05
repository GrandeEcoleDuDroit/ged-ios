import Foundation

extension Int64 {
    func toDate() -> Date {
        Date(timeIntervalSince1970: TimeInterval(self) / 1000)
    }
}
