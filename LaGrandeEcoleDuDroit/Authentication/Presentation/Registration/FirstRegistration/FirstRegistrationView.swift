import SwiftUI

struct FirstRegistrationDestination: View {
    let onNextClick: (String, String) -> Void
     
    @StateObject private var viewModel = AuthenticationMainThreadInjector.shared.resolve(FirstRegistrationViewModel.self)
    
    var body: some View {
        FirstRegistrationView(
            firstName: viewModel.uiState.firstName,
            lastName: viewModel.uiState.lastName,
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
    let firstName: String
    let lastName: String
    let firstNameError: String?
    let lastNameError: String?
    let onFirstNameChange: (String) -> String
    let onLastNameChange: (String) -> String
    let onNextClick: (String, String) -> Void
    
    @FocusState private var focusState: Field?
    
    var body: some View {
        VStack(alignment: .leading, spacing: Dimens.mediumPadding) {
            Text(stringResource(.enterNames))
                .font(.title3)
            
            OutlineTextField(
                initialText: firstName,
                onTextChange: onFirstNameChange,
                placeHolder: stringResource(.firstName),
                errorMessage: firstNameError
            )
            .setTextFieldFocusState(focusState: _focusState, field: .firstName)
            
            OutlineTextField(
                initialText: lastName,
                onTextChange: onLastNameChange,
                placeHolder: stringResource(.lastName),
                errorMessage: lastNameError
            )
            .setTextFieldFocusState(focusState: _focusState, field: .lastName)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding()
        .onTapGesture { focusState = nil }
        .contentShape(Rectangle())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(stringResource(.registration))
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button(
                    action: {
                        onNextClick(firstName, lastName)
                    }, label: {
                        Text(stringResource(.next))
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
            firstName: "",
            lastName: "",
            firstNameError: nil,
            lastNameError: nil,
            onFirstNameChange: {_ in "" },
            onLastNameChange: {_ in "" },
            onNextClick: {_, _ in}
        )
    }
}
