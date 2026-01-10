import Foundation

enum AuthenticationError: Error {
    case invalidCredentials
    case userNotConnected
    case userDisabled
    case authUserNotFound
    case emailAlreadyInUse
}

extension AuthenticationError: LocalizedError {
    var errorDescription: String? {
        switch self {
            case .invalidCredentials: stringResource(.incorrectCredentialsError)
            case .userNotConnected: ""
            case .userDisabled: stringResource(.disabledUserError)
            case .authUserNotFound: stringResource(.authUserNotFoundError)
            case .emailAlreadyInUse: stringResource(.emailAlreadyAssociatedError)
        }
    }
}
