enum AuthenticationScreenState {
    case initial
    case loading
    case error(message: String)
    case emailSent
}
