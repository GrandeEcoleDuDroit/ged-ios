import SwiftUI
import Combine

class FirstRegistrationViewModel: ViewModel {
    @Published var uiState: FirstRegistrationUiState = FirstRegistrationUiState()
    
    func onFirstNameChanged(_ firstName: String) {
        uiState.firstName = validName(firstName)
    }
    
    func onLastNameChanged(_ lastName: String) {
        uiState.lastName = validName(lastName)
    }
    
    func validateInputs() -> Bool {
        uiState.firstName = uiState.firstName.trimmedAndCapitalizedFirstLetter()
        uiState.lastName = uiState.lastName.trimmedAndCapitalizedFirstLetter()
        uiState.firstNameError = uiState.firstName.isBlank() ? stringResource(.mandatoryFieldError) : nil
        uiState.lastNameError = uiState.lastName.isBlank() ? stringResource(.mandatoryFieldError) : nil
        
        return uiState.firstNameError == nil && uiState.lastNameError == nil
    }
    
    private func validName(_ name: String) -> String {
        name.filter { $0.isLetter || $0 == " " || $0 == "-" }
    }
    
    struct FirstRegistrationUiState {
        var firstName: String = ""
        var lastName: String = ""
        fileprivate(set) var firstNameError: String? = nil
        fileprivate(set) var lastNameError: String? = nil
    }
}
