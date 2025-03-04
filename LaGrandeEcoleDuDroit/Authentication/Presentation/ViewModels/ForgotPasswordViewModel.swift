import Combine
import Foundation

class ForgotPasswordViewModel: ObservableObject {
    private let resetPasswordUseCase: ResetPasswordUseCase
    
    @Published var email: String = ""
    @Published private(set) var screenState: AuthenticationScreenState = .initial
    
    init(resetPasswordUseCase: ResetPasswordUseCase) {
        self.resetPasswordUseCase = resetPasswordUseCase
    }
    
    func resetPassword() {
        updateScreenState(.loading)
        
        Task {
            do {
                try await resetPasswordUseCase.execute(email: email)
                updateScreenState(.emailSent)
            }
            catch AuthenticationError.tooManyRequests {
                updateScreenState(.error(message: getString(.tooManyRequestsError)))
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
            } catch {
                updateScreenState(.error(message: getString(.unknownError)))
            }
        }
    }
    
    func updateScreenState(_ screenState: AuthenticationScreenState) {
        if Thread.isMainThread {
            self.screenState = screenState
        } else {
            DispatchQueue.main.sync {
                self.screenState = screenState
            }
        }
    }
    
    func validateInput() -> Bool {
        guard !email.isBlank else {
            screenState = .error(message: getString(.emptyInputError))
            return false
        }
        
        guard VerifyEmailFormatUseCase.execute(email) else {
            screenState = .error(message: getString(.invalidEmailError))
            return false
        }
        
        return true
    }
}
