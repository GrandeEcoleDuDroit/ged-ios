enum RegistrationState: Equatable {
    case idle
    case loading
    case error(message: String)
    case registered
    case emailVerified
}
