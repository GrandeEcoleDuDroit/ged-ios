enum AuthenticationState: Equatable {
    case idle
    case loading
    case error(message: String)
    case authenticated
    case unauthenticated
    case emailNotVerified
}
