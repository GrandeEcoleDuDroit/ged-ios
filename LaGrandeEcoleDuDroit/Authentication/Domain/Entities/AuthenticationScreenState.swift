enum AuthenticationScreenState: Equatable {
    case initial
    case loading
    case error(message: String)
    case emailSent
    case authenticated
    case emailNotVerified
    case emailVerified
}
