enum AuthenticationError: Error {
    case invalidCredentials
    case userNotFound
    case accountAlreadyExist
    case userNotConnected
    case userDisabled
    case network
    case tooManyRequests
    case unknown
}
