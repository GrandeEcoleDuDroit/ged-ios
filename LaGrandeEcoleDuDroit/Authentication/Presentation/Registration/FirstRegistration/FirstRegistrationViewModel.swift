import SwiftUI
import Combine

class FirstRegistrationViewModel: ViewModel {
    @Published var uiState = FirstRegistrationUiState()
    private let maxNameLength: Int = 50
    
    func onFirstNameChange(_ firstName: String) {
        uiState.firstName = validNameChanges(firstName)
    }
    
    func onLastNameChange(_ lastName: String) {
        uiState.lastName = validNameChanges(lastName)
    }
    
    func validateInputs() -> Bool {
        let (firstName, lastName) = (uiState.firstName, uiState.lastName)
        uiState.firstName = UserUtils.Name.formatName(firstName.trim())
        uiState.lastName = UserUtils.Name.formatName(lastName.trim())
        uiState.firstNameError = validateName(firstName)
        uiState.lastNameError = validateName(lastName)
        
        return uiState.firstNameError == nil && uiState.lastNameError == nil
    }
    
    private func validNameChanges(_ name: String) -> String {
        name.take(maxNameLength).filter { $0.isLetter || $0 == " " || $0 == "-" }
    }
    
    private func validateName(_ name: String) -> String? {
        if name.isBlank() {
            stringResource(.mandatoryFieldError)
        } else {
            nil
        }
    }
    
    struct FirstRegistrationUiState {
        var firstName: String = ""
        var lastName: String = ""
        fileprivate(set) var firstNameError: String? = nil
        fileprivate(set) var lastNameError: String? = nil
    }
}
