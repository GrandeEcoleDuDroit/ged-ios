import Foundation

enum ElapsedTime: Equatable {
    case now(seconds: Int)
    case minute(minutes: Int)
    case hour(hours: Int)
    case day(days: Int)
    case later(date: Date)
}
