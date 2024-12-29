import SwiftUI
import Combine

class RegistrationViewModel: ObservableObject {
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var email: String
    @Published var password: String = ""
    @Published var schoolLevel: String
    @Published var registrationState: RegistrationState = .idle
    let schoolLevels = ["GED 1", "GED 2", "GED 3", "GED 4"]
    let maxStep = 3
    
    private let registerUseCase: RegisterUseCase
    private let sendVerificationEmailUseCase: SendVerificationEmailUseCase
    private let isEmailVerifiedUseCase: IsEmailVerifiedUseCase
    private let createUserUseCase: CreateUserUseCase
    
    init(
        email: String = "",
        registerUseCase: RegisterUseCase,
        sendVerificationEmailUseCase: SendVerificationEmailUseCase,
        isEmailVerifiedUseCase: IsEmailVerifiedUseCase,
        createUserUseCase: CreateUserUseCase
    ) {
        self.email = email
        self.registerUseCase = registerUseCase
        self.sendVerificationEmailUseCase = sendVerificationEmailUseCase
        self.isEmailVerifiedUseCase = isEmailVerifiedUseCase
        self.createUserUseCase = createUserUseCase
        
        schoolLevel = schoolLevels[0]
    }
    
    func nameInputsNotEmpty() -> Bool {
        !(firstName.isBlank || lastName.isBlank)
    }
    
    func credentialInputsNotEmpty() -> Bool {
        !(email.isBlank || password.isBlank)
    }
    
    func validateCredentialInputs() -> Bool {
        guard VerifyEmailFormatUseCase.execute(email) else {
            registrationState = .error(message: getString(.invalidEmailError))
            return false
        }
        
        guard password.count >= 8 else {
            registrationState = .error(message: getString(.passwordLengthError))
            return false
        }
        
        return true
    }
    
    func register() async {
        await updateRegistrationState(to: .loading)
        let formattedFirstName = self.firstName.trimmedAndCapitalizedFirstLetter
        let formattedLastName = self.lastName.trimmedAndCapitalizedFirstLetter
        let formattedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let formattedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        
        do {
            let userId = try await registerUseCase.execute(email: formattedEmail, password: formattedPassword)
            let user = User(
                id: userId,
                firstName: formattedFirstName,
                lastName: formattedLastName,
                email: formattedEmail,
                schoolLevel: schoolLevel,
                isMember: false,
                profilePictureUrl: nil
            )
            try await createUserUseCase.execute(user: user)
            await updateRegistrationState(to: .registered)
        }
        catch AuthenticationError.accountAlreadyExist {
            await updateRegistrationState(to: .error(message: getString(.accountAlreadyInUseError)))
        }
        catch AuthenticationError.userNotFound {
            await updateRegistrationState(to: .error(message: getString(.authUserNotFound)))
        }
        catch RequestError.invalidResponse(let error) {
            print(error ?? "Query error")
            await updateRegistrationState(to: .error(message: getString(.registrationError)))
        }
        catch NetworkError.timedOut {
            await updateRegistrationState(to: .error(message: getString(.timedOutError)))
        }
        catch NetworkError.notConnectedToInternet {
            await updateRegistrationState(to: .error(message: getString(.notConnectedToInternetError)))
        }
        catch {
            await updateRegistrationState(to: .error(message: getString(.registrationError)))
        }
    }
    
    func sendVerificationEmail() async {
        await updateRegistrationState(to: .loading)
        do {
            try await sendVerificationEmailUseCase.execute()
            await updateRegistrationState(to: .idle)
        }
        catch NetworkError.tooManyRequests {
            await updateRegistrationState(to: .error(message: getString(.tooManyRequestError)))
        }
        catch {
            await updateRegistrationState(to: .error(message: getString(.registrationError)))
        }
    }
    
    func checkVerifiedEmail() async {
        await updateRegistrationState(to: .loading)

        if let emailVerified = try? await isEmailVerifiedUseCase.execute() {
            if emailVerified {
                await updateRegistrationState(to: .emailVerified )
            } else {
                await updateRegistrationState(to: .error(message: getString(.emailNotVerifiedError)))
            }
        } else {
            await updateRegistrationState(to: .error(message: getString(.emailNotVerifiedError)))
        }
    }
    
    func resetState() {
        registrationState = .idle
    }
    
    private func updateRegistrationState(to state: RegistrationState) async {
        await MainActor.run {
            registrationState = state
        }
    }
}
