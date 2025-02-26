enum AuthenticationState: Equatable {
    case idle
    case waiting
    case loading
    case error(message: String)
    case authenticated
    case unauthenticated
    case emailNotVerified
    case emailVerified
}
