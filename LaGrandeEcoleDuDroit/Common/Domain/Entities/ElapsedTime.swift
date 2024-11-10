import Foundation

enum ElapsedTime {
    case now(seconds: Int)
    case minute(minutes: Int)
    case hour(hours: Int)
    case day(days: Int)
    case week(weeks: Int)
    case later(date: Date)
}
