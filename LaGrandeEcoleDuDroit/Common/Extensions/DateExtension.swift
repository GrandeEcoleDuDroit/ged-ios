import Foundation

extension Date {
    func toEpochMilli() -> Int64 {
        Int64(self.timeIntervalSince1970 * 1000)
    }
    
    func isAlmostEqual(to other: Date, tolerance: TimeInterval = 0.001) -> Bool {
        abs(self.timeIntervalSince(other)) < tolerance
    }
}
