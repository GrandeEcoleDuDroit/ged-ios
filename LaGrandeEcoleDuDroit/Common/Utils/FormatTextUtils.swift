import Foundation

func getElapsedTimeText(date: Date) -> String {
    switch GetElapsedTimeUseCase.execute(date: date) {
        case .now(_): stringResource(.now)
        case let .minute(minutes): stringResource(.minutesAgoShort, minutes)
        case let .hour(hours): stringResource(.hoursAgoShort, hours)
        case let .day(days): stringResource(.daysAgoShort, days)
        case let .week(weeks): stringResource(.weeksAgoShort, weeks)
        default: date.formatted(.dateTime.year().month().day())
    }
}
