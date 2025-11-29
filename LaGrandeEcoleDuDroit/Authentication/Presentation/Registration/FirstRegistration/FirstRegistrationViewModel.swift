import SwiftUI
import Combine

class FirstRegistrationViewModel: ViewModel {
    @Published private(set) var uiState = FirstRegistrationUiState()
    
    func onFirstNameChanged(_ firstName: String) -> String {
        let firstName = validName(firstName)
        uiState.firstName = firstName
        return firstName
    }
    
    func onLastNameChanged(_ lastName: String) -> String {
        let lastName = validName(lastName)
        uiState.lastName = lastName
        return lastName
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
        fileprivate(set) var firstName: String = ""
        fileprivate(set) var lastName: String = ""
        fileprivate(set) var firstNameError: String? = nil
        fileprivate(set) var lastNameError: String? = nil
    }
}
