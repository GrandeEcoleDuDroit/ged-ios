import SwiftUI
import Combine

class AuthenticationViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var authenticationState: AuthenticationState = .idle
    private var cancellables: Set<AnyCancellable> = []
    
    private let loginUseCase: LoginUseCase
    private let isEmailVerifiedUseCase: IsEmailVerifiedUseCase
    private let isAuthenticatedUseCase: IsAuthenticatedUseCase
    private let getUserUseCase: GetUserUseCase
    private let setCurrentUserUseCase: SetCurrentUserUseCase
    
    init(
        loginUseCase: LoginUseCase,
        isEmailVerifiedUseCase: IsEmailVerifiedUseCase,
        isAuthenticatedUseCase: IsAuthenticatedUseCase,
        getUserUseCase: GetUserUseCase,
        setCurrentUserUseCase: SetCurrentUserUseCase
    ) {
        self.loginUseCase = loginUseCase
        self.isEmailVerifiedUseCase = isEmailVerifiedUseCase
        self.isAuthenticatedUseCase = isAuthenticatedUseCase
        self.getUserUseCase = getUserUseCase
        self.setCurrentUserUseCase = setCurrentUserUseCase
        
        listenAuthenticationState()
    }
    
    func validateInputs() -> Bool {
        guard !email.isEmpty, !password.isEmpty else {
            authenticationState = .error(message: getString(.emptyInputsError))
            return false
        }
        
        guard VerifyEmailFormatUseCase.execute(email) else {
            authenticationState = .error(message: getString(.invalidEmailError))
            return false
        }
        
        guard password.count >= 8 else {
            authenticationState = .error(message: getString(.passwordLengthError))
            return false
        }
        
        return true
    }
    
    func login() {
        updateAuthenticationState(to: .loading)
        
        Task {
            do {
                let userId = try await loginUseCase.execute(email: email, password: password)
                
                if try await isEmailVerifiedUseCase.execute() {
                    let user = await getUserUseCase.execute(userId: userId)
                    if user != nil {
                        setCurrentUserUseCase.execute(user: user!)
                        resetInputs()
                        updateAuthenticationState(to: .authenticated)
                    } else {
                        updateAuthenticationState(to: .error(message: getString(.userNotExist)))
                    }
                } else {
                    updateAuthenticationState(to: .emailNotVerified)
                }
            } catch AuthenticationError.invalidCredentials {
                updateAuthenticationState(to: .error(message: getString(.invalidCredentials)))
            } catch AuthenticationError.userDisabled {
                updateAuthenticationState(to: .error(message: getString(.userDisabled)))
            } catch {
                updateAuthenticationState(to: .error(message: getString(.unknownError)))
            }
        }
    }
    
    private func listenAuthenticationState() {
        isAuthenticatedUseCase.execute()
            .sink(receiveCompletion: { completion in
                switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        print("Error retrieving authentication state: \(error)")
                }
            }, receiveValue: { [weak self] isAuthenticated in
                self?.authenticationState = isAuthenticated ? .authenticated : .unauthenticated
            })
            .store(in: &cancellables)
    }
    
    private func resetInputs() {
        email = ""
        password = ""
    }
    
    private func updateAuthenticationState(to state: AuthenticationState) {
        if Thread.isMainThread {
            authenticationState = state
        } else {
            DispatchQueue.main.sync { [weak self] in
                self?.authenticationState = state
            }
        }
    }
}
