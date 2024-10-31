enum AuthenticationError: Error {
    case invalidCredentials
    case userNotFound
    case accountAlreadyExist
    case userNotConnected
    case userDisabled
    case network
    case tooManyRequest
    case unknown
}
