import Foundation

func getElapsedTimeValue(date: Date, format: ElapsedTimeValueFormat = .short) -> String {
    switch GetElapsedTimeUseCase.execute(date: date) {
        case .now(_): stringResource(.now)
        case let .minute(minutes):
            switch format {
                case .short: stringResource(.minutesAgoShort, minutes)
                case .long: stringResource(.minutesAgoLong, minutes)
            }
        case let .hour(hours):
            switch format {
                case .short: stringResource(.hoursAgoShort, hours)
                case .long: stringResource(.hoursAgoLong, hours)
            }
        case let .day(days):
            switch format {
                case .short: stringResource(.daysAgoShort, days)
                case .long: stringResource(.daysAgoLong, days)
            }
        case .later: date.formatted(.dateTime.year().month().day())
    }
}

enum ElapsedTimeValueFormat {
    case short
    case long
}
