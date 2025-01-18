import SwiftUI
import Combine

class RegistrationViewModel: ObservableObject {
    private let registerUseCase: RegisterUseCase
    private let createUserUseCase: CreateUserUseCase
    
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var email: String
    @Published var password: String = ""
    @Published var schoolLevel: String
    @Published var registrationState: RegistrationState = .idle
    let schoolLevels = ["GED 1", "GED 2", "GED 3", "GED 4"]
    let maxStep = 3
    
    init(
        email: String = "",
        registerUseCase: RegisterUseCase,
        createUserUseCase: CreateUserUseCase
    ) {
        self.email = email
        self.registerUseCase = registerUseCase
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
        
        Task {
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
            catch RequestError.invalidResponse {
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
    }
    
    func resetState() {
        registrationState = .idle
    }
    
    private func updateRegistrationState(to state: RegistrationState) {
        if Thread.isMainThread {
            registrationState = state
        } else {
            DispatchQueue.main.sync { [weak self] in
                self?.registrationState = state
            }
        }
    }
}
