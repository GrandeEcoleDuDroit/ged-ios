import Foundation

extension Date {
    func toEpochMilli() -> Int64 {
        Int64(self.timeIntervalSince1970 * 1000)
    }
    
    func isAlmostEqual(to other: Date, tolerance: TimeInterval = 0.001) -> Bool {
        abs(self.timeIntervalSince(other)) < tolerance
    }
    
    func plusMinutes(_ value: Int) -> Date {
        Calendar.current.date(byAdding: .minute, value: value, to: self)
            ?? self.addingTimeInterval(TimeInterval(value * 3600))
    }
    
    func plusDays(_ value: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: value, to: self)
            ?? self.addingTimeInterval(TimeInterval(value * 86400))
    }
    
    func minusMinutes(_ value: Int) -> Date {
        Calendar.current.date(byAdding: .minute, value: -value, to: self)
            ?? self.addingTimeInterval(TimeInterval(-value * 3600))
    }
    
    func formatDayMonthYear() -> String {
        let formatter = DateFormatter()
        if Locale.current.identifier.hasPrefix("fr") {
            formatter.dateFormat = "dd MMM yyyy"
        } else {
            formatter.dateFormat = "MMM dd, yyyy"
        }
        return formatter.string(from: self)
    }
}
