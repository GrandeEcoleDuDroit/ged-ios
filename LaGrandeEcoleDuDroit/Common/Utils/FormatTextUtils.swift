import Foundation

func getElapsedTimeText(elapsedTime: ElapsedTime, announcementDate: Date) -> String {
    switch elapsedTime {
        case .now(_):
            getString(.now)
        case.minute(let minutes):
            getString(.minutesAgoShort, minutes)
        case .hour(let hours):
            getString(.hoursAgoShort, hours)
        case .day(let days):
            getString(.daysAgoShort, days)
        case .week(let weeks):
            getString(.weeksAgoShort, weeks)
        default:
            announcementDate.formatted(.dateTime.year().month().day())
    }
}
