import SwiftUI
import Combine

class AuthenticationViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var screenState: AuthenticationScreenState = .initial
    private var cancellables: Set<AnyCancellable> = []
    
    private let loginUseCase: LoginUseCase
    private let isEmailVerifiedUseCase: IsEmailVerifiedUseCase
    private let isAuthenticatedUseCase: IsUserAuthenticatedUseCase
    private let getUserUseCase: GetUserUseCase
    private let setCurrentUserUseCase: SetCurrentUserUseCase
    private let setUserAuthenticatedUseCase: SetUserAuthenticatedUseCase
    
    init(
        loginUseCase: LoginUseCase,
        isEmailVerifiedUseCase: IsEmailVerifiedUseCase,
        isAuthenticatedUseCase: IsUserAuthenticatedUseCase,
        getUserUseCase: GetUserUseCase,
        setCurrentUserUseCase: SetCurrentUserUseCase,
        setUserAuthenticatedUseCase: SetUserAuthenticatedUseCase
    ) {
        self.loginUseCase = loginUseCase
        self.isEmailVerifiedUseCase = isEmailVerifiedUseCase
        self.isAuthenticatedUseCase = isAuthenticatedUseCase
        self.getUserUseCase = getUserUseCase
        self.setCurrentUserUseCase = setCurrentUserUseCase
        self.setUserAuthenticatedUseCase = setUserAuthenticatedUseCase
    }
    
    func validateInputs() -> Bool {
        guard !email.isEmpty, !password.isEmpty else {
            screenState = .error(message: getString(.emptyInputsError))
            return false
        }
        
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
    
    func login() {
        updateScreenState(.loading)
        
        Task {
            do {
                try await loginUseCase.execute(email: email, password: password)
                
                if let user = try await getUserUseCase.executeWithEmail(email: email) {
                    setCurrentUserUseCase.execute(user: user)
                    if try await isEmailVerifiedUseCase.execute() {
                        await setUserAuthenticatedUseCase.execute(true)
                        updateScreenState(.authenticated)
                    } else {
                        updateScreenState(.emailNotVerified)
                    }
                } else {
                    updateScreenState(.error(message: getString(.userNotExist)))
                }
            }
            catch AuthenticationError.invalidCredentials {
                updateScreenState(.error(message: getString(.invalidCredentials)))
            }
            catch AuthenticationError.userDisabled {
                updateScreenState(.error(message: getString(.userDisabled)))
            }
            catch AuthenticationError.network, AuthenticationError.unknown {
                updateScreenState(.error(message: getString(.unknownNetworkError)))
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
            
            clearPassword()
        }
    }
    
    private func clearPassword() {
        if Thread.isMainThread {
            password = ""
        } else {
            DispatchQueue.main.sync { [weak self] in
                self?.password = ""
            }
        }
    }
    
    private func updateScreenState(_ state: AuthenticationScreenState) {
        if Thread.isMainThread {
            screenState = state
        } else {
            DispatchQueue.main.sync { [weak self] in
                self?.screenState = state
            }
        }
    }
}
