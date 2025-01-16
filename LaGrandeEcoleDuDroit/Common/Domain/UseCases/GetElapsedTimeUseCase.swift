import Foundation

class GetElapsedTimeUseCase {
    static func execute(date: Date) -> ElapsedTime {
        let duration = Date().timeIntervalSince(date)
        
        let seconds = Int(duration)
        let minutes = Int(duration) / 60
        let hours = Int(duration) / 3600
        let days = Int(duration) / 86400
        let weeks = days / 7
        
        switch duration {
            case 0..<60:
                return .now(seconds: seconds)
            case 60..<3600:
                return .minute(minutes: minutes)
            case 3600..<86400:
                return .hour(hours: hours)
            case 86400..<604800:
                return .day(days: days)
            case 604800..<2592000:
                return .week(weeks: weeks)
            default:
                return .later(date: date)
        }
    }
}
