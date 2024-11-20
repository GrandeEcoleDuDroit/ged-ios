import Foundation

func getString(gedString: String) -> String {
    return NSLocalizedString(gedString, comment: "")
}

func getString(gedString: String, _ args: CVarArg...) -> String {
    let value = NSLocalizedString(gedString, comment: "")
    return String(format: value, arguments: args)
}

func verifyEmail(_ email: String) -> Bool {
    let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Z|a-z]{2,}"
    let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
    return emailPredicate.evaluate(with: email)
}

func getElapsedTime(date: Date) -> ElapsedTime {
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
