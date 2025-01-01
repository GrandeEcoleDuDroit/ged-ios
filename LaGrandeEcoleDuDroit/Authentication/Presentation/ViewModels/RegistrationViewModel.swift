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
    private var registrationTasks: [Task<Void, Never>] = []
    
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
    
    func register() {
        updateRegistrationState(to: .loading)
        
        let formattedFirstName = self.firstName.trimmedAndCapitalizedFirstLetter
        let formattedLastName = self.lastName.trimmedAndCapitalizedFirstLetter
        let formattedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let formattedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let task = Task {
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
                updateRegistrationState(to: .registered)
            }
            catch AuthenticationError.accountAlreadyExist {
                updateRegistrationState(to: .error(message: getString(.accountAlreadyInUseError)))
            }
            catch AuthenticationError.userNotFound {
                updateRegistrationState(to: .error(message: getString(.authUserNotFound)))
            }
            catch RequestError.invalidResponse(let error) {
                updateRegistrationState(to: .error(message: getString(.registrationError)))
            }
            catch NetworkError.timedOut {
                updateRegistrationState(to: .error(message: getString(.timedOutError)))
            }
            catch NetworkError.notConnectedToInternet {
                updateRegistrationState(to: .error(message: getString(.notConnectedToInternetError)))
            }
            catch {
                updateRegistrationState(to: .error(message: getString(.registrationError)))
            }
        }
        
        registrationTasks.append(task)
    }
    
    func sendVerificationEmail() {
        updateRegistrationState(to: .loading)
        
        let task = Task {
            do {
                try await sendVerificationEmailUseCase.execute()
                updateRegistrationState(to: .idle)
            }
            catch NetworkError.tooManyRequests {
                updateRegistrationState(to: .error(message: getString(.tooManyRequestError)))
            }
            catch {
                updateRegistrationState(to: .error(message: getString(.registrationError)))
            }
        }
        
        registrationTasks.append(task)
    }
    
    func checkVerifiedEmail() {
        updateRegistrationState(to: .loading)

        let task = Task {
            if let emailVerified = try? await isEmailVerifiedUseCase.execute() {
                if emailVerified {
                    updateRegistrationState(to: .emailVerified )
                } else {
                    updateRegistrationState(to: .error(message: getString(.emailNotVerifiedError)))
                }
            } else {
                updateRegistrationState(to: .error(message: getString(.emailNotVerifiedError)))
            }
        }
        
        registrationTasks.append(task)
    }
    
    func resetState() {
        registrationState = .idle
    }
    
    private func updateRegistrationState(to state: RegistrationState) {
        DispatchQueue.main.async { [weak self] in
            self?.registrationState = state
        }
    }
    
    deinit {
        registrationTasks.forEach { $0.cancel() }
    }
}
