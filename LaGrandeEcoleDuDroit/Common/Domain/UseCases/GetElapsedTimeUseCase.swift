import Foundation

class GetElapsedTimeUseCase {
    static func execute(date: Date) -> ElapsedTime {
        let duration = Date().timeIntervalSince(date)
        
        let seconds = Int(duration)
        let minutes = Int(duration) / 60
        let hours = Int(duration) / 3600
        let days = Int(duration) / 86400
        let weeks = days / 7
        
        return switch duration {
            case 0..<60: .now(seconds: seconds)
            case 60..<3600: .minute(minutes: minutes)
            case 3600..<86400: .hour(hours: hours)
            case 86400..<604800: .day(days: days)
            case 604800..<2592000: .week(weeks: weeks)
            default: .later(date: date)
        }
    }
}
