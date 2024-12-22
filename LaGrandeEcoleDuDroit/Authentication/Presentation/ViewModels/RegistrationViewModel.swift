import SwiftUI
import Combine

class RegistrationViewModel: ObservableObject {
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var email: String = ""
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
        registerUseCase: RegisterUseCase,
        sendVerificationEmailUseCase: SendVerificationEmailUseCase,
        isEmailVerifiedUseCase: IsEmailVerifiedUseCase,
        createUserUseCase: CreateUserUseCase
    ) {
        self.registerUseCase = registerUseCase
        self.sendVerificationEmailUseCase = sendVerificationEmailUseCase
        self.isEmailVerifiedUseCase = isEmailVerifiedUseCase
        self.createUserUseCase = createUserUseCase
        
        schoolLevel = schoolLevels[0]
    }
    
    func validateNameInputs() -> Bool {
        guard !firstName.isEmpty, !lastName.isEmpty else {
            registrationState = .error(message: getString(gedString: GedString.empty_inputs_error))
            return false
        }
        
        return true
    }
    
    func validateCredentialInputs() -> Bool {
        guard !email.isEmpty, !password.isEmpty else {
            registrationState = .error(message: getString(gedString: GedString.empty_inputs_error))
            return false
        }
        
        guard VerifyEmailFormatUseCase.execute(email) else {
            registrationState = .error(message: getString(gedString: GedString.invalid_email_error))
            return false
        }
        
        guard password.count >= 8 else {
            registrationState = .error(message: getString(gedString: GedString.password_length_error))
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
            await updateRegistrationState(to: .error(message: getString(gedString: GedString.account_already_in_use_error)))
        }
        catch AuthenticationError.userNotFound {
            await updateRegistrationState(to: .error(message: getString(gedString: GedString.auth_user_not_found)))
        }
        catch RequestError.invalidResponse(let error) {
            print(error ?? "Query error")
            await updateRegistrationState(to: .error(message: getString(gedString: GedString.registration_error)))
        }
        catch NetworkError.timedOut {
            await updateRegistrationState(to: .error(message: getString(gedString: GedString.timed_out_error)))
        }
        catch NetworkError.notConnectedToInternet {
            await updateRegistrationState(to: .error(message: getString(gedString: GedString.not_connected_to_internet_error)))
        }
        catch {
            await updateRegistrationState(to: .error(message: getString(gedString: GedString.registration_error)))
        }
    }
    
    func sendVerificationEmail() async {
        await updateRegistrationState(to: .loading)
        do {
            try await sendVerificationEmailUseCase.execute()
            await updateRegistrationState(to: .idle)
        }
        catch NetworkError.tooManyRequests {
            await updateRegistrationState(to: .error(message: getString(gedString: GedString.too_many_request_error)))
        }
        catch {
            await updateRegistrationState(to: .error(message: getString(gedString: GedString.registration_error)))
        }
    }
    
    func checkVerifiedEmail() async {
        await updateRegistrationState(to: .loading)

        if let emailVerified = try? await isEmailVerifiedUseCase.execute() {
            if emailVerified {
                await updateRegistrationState(to: .emailVerified )
            } else {
                await updateRegistrationState(to: .error(message: getString(gedString: GedString.email_not_verified_error)))
            }
        } else {
            await updateRegistrationState(to: .error(message: getString(gedString: GedString.email_not_verified_error)))
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
