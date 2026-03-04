import Foundation

class GetElapsedTimeUseCase {
    static func execute(date: Date) -> ElapsedTime {
        let duration = Date().timeIntervalSince(date)
        
        let seconds = Int(duration)
        let minutes = Int(duration) / 60
        let hours = Int(duration) / 3600
        let days = Int(duration) / 86400
        
        return switch duration {
            case 0..<60: .now(seconds: seconds)
            case 60..<3600: .minute(minutes: minutes)
            case 3600..<86400: .hour(hours: hours)
            case 86400..<2592000: .day(days: days)
            default: .later(date: date)
        }
    }
}
