import SwiftUI
import Combine

class RegistrationViewModel: ObservableObject {
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var schoolLevel: String
    @Published var isRegistered: Bool = false
    let schoolLevels = ["GED 1", "GED 2", "GED 3", "GED 4"]
    let maxStep = 3
    private let registerUseCase: RegisterUseCase = RegisterUseCase()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        schoolLevel = schoolLevels[0]
    }
    
    func validateNameInputs() -> Bool {
        guard !firstName.isEmpty, !lastName.isEmpty else {
            errorMessage = NSLocalizedString(GedString.empty_inputs_error, comment: "")
            return false
        }
        
        return true
    }
    
    func validateCredentialInputs() -> Bool {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = NSLocalizedString(GedString.empty_inputs_error, comment: "")
            return false
        }
        
        guard verifyEmail(email) else {
            errorMessage = NSLocalizedString(GedString.invalid_email_error, comment: "")
            return false
        }
        
        guard password.count >= 8 else {
            errorMessage = NSLocalizedString(GedString.password_length_error, comment: "")
            return false
        }
        
        return true
    }
    
    func register() {
        self.isLoading = true
        registerUseCase.execute(email: email, password: password)
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    self.isLoading = false
                    self.errorMessage = getString(gedString: GedString.registration_error)
                    self.isRegistered = false
                }
            }, receiveValue: {
                self.isLoading = false
                self.isRegistered = true
            })
            .store(in: &cancellables)
    }
}
