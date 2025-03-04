import SwiftUI
import Combine

class RegistrationViewModel: ObservableObject {
    private let registerUseCase: RegisterUseCase
    private let createUserUseCase: CreateUserUseCase
    private let isUserExistUseCase: IsUserExistUseCase
    
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var email: String
    @Published var password: String = ""
    @Published var schoolLevel: String
    @Published var screenState: RegistrationScreenState = .initial
    let schoolLevels = ["GED 1", "GED 2", "GED 3", "GED 4"]
    let maxStep = 3
    
    init(
        email: String = "",
        registerUseCase: RegisterUseCase,
        createUserUseCase: CreateUserUseCase,
        isUserExistUseCase: IsUserExistUseCase
    ) {
        self.email = email
        self.registerUseCase = registerUseCase
        self.createUserUseCase = createUserUseCase
        self.isUserExistUseCase = isUserExistUseCase
        
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
            screenState = .error(message: getString(.invalidEmailError))
            return false
        }
        
        guard password.count >= 8 else {
            screenState = .error(message: getString(.passwordLengthError))
            return false
        }
        
        return true
    }
    
    func register() {
        updateScreenState(.loading)
        
        let formattedFirstName = self.firstName.trimmedAndCapitalizedFirstLetter
        let formattedLastName = self.lastName.trimmedAndCapitalizedFirstLetter
        let formattedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let formattedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        
        Task {
            do {
                guard try await !isUserExistUseCase.execute(email: formattedEmail) else {
                    updateScreenState(.error(message: getString(.accountAlreadyInUseError)))
                    return
                }
                
                let user = User(
                    id: GenerateIdUseCase().execute(),
                    firstName: formattedFirstName,
                    lastName: formattedLastName,
                    email: formattedEmail,
                    schoolLevel: schoolLevel,
                    isMember: false,
                    profilePictureUrl: nil
                )
                
                try await createUserUseCase.execute(user: user)
                try await registerUseCase.execute(email: formattedEmail, password: formattedPassword)
                updateScreenState(.registered)
            }
            catch AuthenticationError.accountAlreadyExist {
                updateScreenState(.error(message: getString(.accountAlreadyInUseError)))
            }
            catch AuthenticationError.userNotFound {
                updateScreenState(.error(message: getString(.authUserNotFound)))
            }
            catch AuthenticationError.tooManyRequests {
                updateScreenState(.error(message: getString(.tooManyRequestsError)))
            }
            catch AuthenticationError.network, AuthenticationError.unknown {
                updateScreenState(.error(message: getString(.unknownNetworkError)))
            }
            catch RequestError.invalidResponse {
                updateScreenState(.error(message: getString(.internalServerError)))
            }
            catch let error as URLError {
                switch error.code {
                    case .notConnectedToInternet:
                        updateScreenState(.error(message: getString(.notConnectedToInternetError)))
                    case .timedOut:
                        updateScreenState(.error(message: getString(.timedOutError)))
                    case .networkConnectionLost:
                        updateScreenState(.error(message: getString(.networkConnectionLostError)))
                    case .cannotFindHost:
                        updateScreenState(.error(message: getString(.cannotFindHostError)))
                    default:
                        updateScreenState(.error(message: getString(.unknownNetworkError)))
                }
            }
            catch {
                updateScreenState(.error(message: getString(.unknownError)))
            }
        }        
    }
    
    func clearEmail() {
        email = ""
    }
    
    func clearPassword() {
        password = ""
    }
    
    func resetSchoolLevel() {
        schoolLevel = schoolLevels[0]
    }
    
    func resetState() {
        screenState = .initial
    }
    
    private func updateScreenState(_ state: RegistrationScreenState) {
        if Thread.isMainThread {
            screenState = state
        } else {
            DispatchQueue.main.sync { [weak self] in
                self?.screenState = state
            }
        }
    }
}
