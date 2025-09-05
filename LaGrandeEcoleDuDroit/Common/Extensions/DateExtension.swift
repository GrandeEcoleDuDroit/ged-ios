import Foundation

extension Date {
    func toEpochMilli() -> Int64 {
        Int64(self.timeIntervalSince1970 * 1000)
    }
}
