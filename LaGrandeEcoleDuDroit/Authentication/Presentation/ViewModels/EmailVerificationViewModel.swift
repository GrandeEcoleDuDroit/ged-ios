import Combine
import Foundation

class EmailVerificationViewModel: ObservableObject {
    @Published var screenState: AuthenticationScreenState = .initial
    private let sendVerificationEmailUseCase: SendEmailVerificationUseCase
    private let setUserAuthenticatedUseCase: SetUserAuthenticatedUseCase
    private let isEmailVerifiedUseCase: IsEmailVerifiedUseCase
    
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
        updateScreenState(.loading)
        
        Task {
            do {
                try await sendVerificationEmailUseCase.execute()
            }
            catch AuthenticationError.userDisabled {
                updateScreenState(.error(message: getString(.userDisabled)))
            }
            catch AuthenticationError.userNotFound {
                updateScreenState(.error(message: getString(.userNotFoundError)))
            }
            catch AuthenticationError.userNotConnected {
                updateScreenState(.error(message: getString(.userNotConnected)))
            }
            catch AuthenticationError.tooManyRequests {
                updateScreenState(.error(message: getString(.tooManyRequestsError)))
            }
            catch AuthenticationError.unknown {
                updateScreenState(.error(message: getString(.unknownError)))
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
    
    func checkVerifiedEmail() {
        updateScreenState(.loading)

        Task {
            do {
                let emailVerified = try await isEmailVerifiedUseCase.execute()
                if emailVerified {
                    updateScreenState(.emailVerified)
                    await setUserAuthenticatedUseCase.execute(true)
                } else {
                    updateScreenState(.error(message: getString(.emailNotVerifiedError)))
                }
            }
            catch AuthenticationError.userDisabled {
                updateScreenState(.error(message: getString(.userDisabled)))
            }
            catch AuthenticationError.userNotFound {
                updateScreenState(.error(message: getString(.userNotFoundError)))
            }
            catch AuthenticationError.userNotConnected {
                updateScreenState(.error(message: getString(.userNotConnected)))
            }
            catch AuthenticationError.tooManyRequests {
                updateScreenState(.error(message: getString(.tooManyRequestsError)))
            }
            catch AuthenticationError.unknown {
                updateScreenState(.error(message: getString(.unknownError)))
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
