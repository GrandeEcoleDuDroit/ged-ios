import Foundation

enum UserError: Error {
    case currentUserNotFound
    case userNotFound
}

extension UserError: LocalizedError {
    var errorDescription: String? {
        switch self {
            case .currentUserNotFound: stringResource(.currentUserNotFoundError)
            case .userNotFound: stringResource(.noUser)
        }
    }
}
