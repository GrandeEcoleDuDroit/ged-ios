enum AuthenticationScreen: Screen {
    case forgottenPassword
    case firstRegistration
    case secondRegistration
    case thirdRegistration
    case emailVerification(email: String)
}
