import SwiftUI

struct FirstRegistrationDestination: View {
    let onNextClick: (String, String) -> Void
     
    @StateObject private var viewModel = AuthenticationMainThreadInjector.shared.resolve(FirstRegistrationViewModel.self)
    @State private var focusedInputField: InputField?
    @State private var isValidNameInputs = false
    
    var body: some View {
        FirstRegistrationView(
            firstName: $viewModel.uiState.firstName,
            lastName: $viewModel.uiState.lastName,
            firstNameError: viewModel.uiState.firstNameError,
            lastNameError: viewModel.uiState.lastNameError,
            onFirstNameChange: viewModel.onFirstNameChanged,
            onLastNameChange: viewModel.onLastNameChanged,
            onNextClick: { firstName, lastName in
                if (viewModel.validateInputs()) {
                    onNextClick(firstName, lastName)
                }
            }
        )
    }
}

private struct FirstRegistrationView: View {
    @Binding var firstName: String
    @Binding var lastName: String
    let firstNameError: String?
    let lastNameError: String?
    let onFirstNameChange: (String) -> Void
    let onLastNameChange: (String) -> Void
    let onNextClick: (String, String) -> Void
    @State private var focusedInputField: InputField?
    @State private var firstNameInput: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: GedSpacing.medium) {
            Text(getString(.enterNames))
                .font(.title3)
            
            OutlineTextField(
                label: getString(.firstName),
                text: $firstName,
                inputField: InputField.firstName,
                focusedInputField: $focusedInputField,
                errorMessage: firstNameError
            )
            
            OutlineTextField(
                label: getString(.lastName),
                text: $lastName,
                inputField: InputField.lastName,
                focusedInputField: $focusedInputField,
                errorMessage: lastNameError
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding()
        .onChange(of: firstName) { newValue in
            onFirstNameChange(newValue)
        }
        .onChange(of: lastName) { newValue in
            onLastNameChange(newValue)
        }
        .contentShape(Rectangle())
        .onTapGesture { focusedInputField = nil }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(getString(.registration))
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button(
                    action: {
                        onNextClick(firstName, lastName)
                    }, label: {
                        Text(getString(.next))
                            .foregroundStyle(.gedPrimary)
                            .fontWeight(.semibold)
                    }
                )
            }
        }
    }
}

#Preview {
    NavigationStack {
        FirstRegistrationView(
            firstName: .constant(""),
            lastName: .constant(""),
            firstNameError: nil,
            lastNameError: nil,
            onFirstNameChange: {_ in},
            onLastNameChange: {_ in},
            onNextClick: {_, _ in}
        )
    }
}
