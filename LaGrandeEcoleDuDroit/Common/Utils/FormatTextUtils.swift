import Foundation

func getElapsedTimeText(elapsedTime: ElapsedTime, announcementDate: Date) -> String {
    switch elapsedTime {
        case .now(_):
            stringResource(.now)
        case.minute(let minutes):
            stringResource(.minutesAgoShort, minutes)
        case .hour(let hours):
            stringResource(.hoursAgoShort, hours)
        case .day(let days):
            stringResource(.daysAgoShort, days)
        case .week(let weeks):
            stringResource(.weeksAgoShort, weeks)
        default:
            announcementDate.formatted(.dateTime.year().month().day())
    }
}
