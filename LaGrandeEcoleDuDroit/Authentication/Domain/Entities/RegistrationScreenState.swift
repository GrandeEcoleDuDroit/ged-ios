enum RegistrationScreenState: Equatable {
    case initial
    case loading
    case error(message: String)
    case registered
}
