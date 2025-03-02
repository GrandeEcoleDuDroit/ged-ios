import Combine
import Foundation

class ForgottenPasswordViewModel: ObservableObject {
    private let resetPasswordUseCase: ResetPasswordUseCase
    private var cancellables: Set<AnyCancellable> = []
    
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
            } catch let error as URLError {
                updateScreenState(.error(message: error.localizedDescription))
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
}
