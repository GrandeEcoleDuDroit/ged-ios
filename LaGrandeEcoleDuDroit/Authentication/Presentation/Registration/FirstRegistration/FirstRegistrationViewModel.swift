import SwiftUI
import Combine

class FirstRegistrationViewModel: ObservableObject {
    @Published var uiState: FirstRegistrationUiState = FirstRegistrationUiState()
    
    func onFirstNameChanged(_ firstName: String) {
        uiState.firstName = validName(firstName)
    }
    
    func onLastNameChanged(_ lastName: String) {
        uiState.lastName = validName(lastName)
    }
    
    func validateInputs() -> Bool {
        uiState.firstName = uiState.firstName.capitalizeWords
        uiState.lastName = uiState.lastName.capitalizeWords
        uiState.firstNameError = uiState.firstName.isBlank ? getString(.mandatoryFieldError) : nil
        uiState.lastNameError = uiState.lastName.isBlank ? getString(.mandatoryFieldError) : nil
        
        return uiState.firstNameError == nil && uiState.lastNameError == nil
    }
    
    private func validName(_ name: String) -> String {
        return name.filter { $0.isLetter || $0 == " " || $0 == "-" }
    }
    
    struct FirstRegistrationUiState {
        var firstName: String = ""
        var lastName: String = ""
        var firstNameError: String? = nil
        var lastNameError: String? = nil
    }
}
