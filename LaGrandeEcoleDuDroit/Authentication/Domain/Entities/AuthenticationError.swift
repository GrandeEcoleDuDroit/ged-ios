enum AuthenticationError: Error {
    case invalidCredentials
    case userNotFound
    case userNotConnected
    case userDisabled
}
