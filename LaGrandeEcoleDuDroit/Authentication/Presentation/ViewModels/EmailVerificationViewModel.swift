import Combine
import Foundation

class EmailVerificationViewModel: ObservableObject {
    @Published var authenticationState: AuthenticationState = .idle
    private let sendVerificationEmailUseCase: SendEmailVerificationUseCase
    private let setUserAuthenticatedUseCase: SetUserAuthenticatedUseCase
    private let isEmailVerifiedUseCase: IsEmailVerifiedUseCase
    private var emailVerificationTask: [Task<Void, Never>] = []
    
    init(
        sendVerificationEmailUseCase: SendEmailVerificationUseCase,
        isEmailVerifiedUseCase: IsEmailVerifiedUseCase,
        setUserAuthenticatedUseCase: SetUserAuthenticatedUseCase
    ) {
        self.sendVerificationEmailUseCase = sendVerificationEmailUseCase
        self.isEmailVerifiedUseCase = isEmailVerifiedUseCase
        self.setUserAuthenticatedUseCase = setUserAuthenticatedUseCase
    }
    
    func sendVerificationEmail() {
        updateAuthenticationState(to: .loading)
        
        let task = Task {
            do {
                try await sendVerificationEmailUseCase.execute()
                updateAuthenticationState(to: .idle)
            }
            catch NetworkError.tooManyRequests {
                updateAuthenticationState(to: .error(message: getString(.tooManyRequestError)))
            }
            catch {
                updateAuthenticationState(to: .error(message: getString(.registrationError)))
            }
        }
        
        emailVerificationTask.append(task)
    }
    
    func checkVerifiedEmail() {
        updateAuthenticationState(to: .loading)

        let task = Task {
            if let emailVerified = try? await isEmailVerifiedUseCase.execute() {
                if emailVerified {
                    updateAuthenticationState(to: .emailVerified)
                    await setUserAuthenticatedUseCase.execute(true)
                } else {
                    updateAuthenticationState(to: .error(message: getString(.emailNotVerifiedError)))
                }
            } else {
                updateAuthenticationState(to: .error(message: getString(.emailNotVerifiedError)))
            }
        }
        
        emailVerificationTask.append(task)
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
    
    deinit {
        emailVerificationTask.forEach { $0.cancel() }
    }
}
