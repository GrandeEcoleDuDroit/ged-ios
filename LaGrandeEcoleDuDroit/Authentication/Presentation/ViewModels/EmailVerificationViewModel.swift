import Combine
import Foundation

class EmailVerificationViewModel: ObservableObject {
    @Published var authenticationState: AuthenticationState = .idle
    private let sendVerificationEmailUseCase: SendVerificationEmailUseCase
    private let isEmailVerifiedUseCase: IsEmailVerifiedUseCase
    private var emailVerificationTask: [Task<Void, Never>] = []
    
    init(
        sendVerificationEmailUseCase: SendVerificationEmailUseCase,
        isEmailVerifiedUseCase: IsEmailVerifiedUseCase
    ) {
        self.sendVerificationEmailUseCase = sendVerificationEmailUseCase
        self.isEmailVerifiedUseCase = isEmailVerifiedUseCase
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
