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
    let onFirstNameChange: (String) -> Void
    let onLastNameChange: (String) -> Void
    let onNextClick: (String, String) -> Void
    
    @FocusState private var focusState: Field?
    
    var body: some View {
        VStack(alignment: .leading, spacing: GedSpacing.medium) {
            Text(getString(.enterNames))
                .font(.title3)
            
            OutlineTextField(
                label: getString(.firstName),
                text: Binding(
                    get: { firstName },
                    set: onFirstNameChange
                ),
                errorMessage: firstNameError,
                focusState: _focusState,
                field: .firstName
            )
            
            OutlineTextField(
                label: getString(.lastName),
                text: Binding(
                    get: { lastName },
                    set: onLastNameChange
                ),
                errorMessage: lastNameError,
                focusState: _focusState,
                field: .lastName
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding()
        .onTapGesture { focusState = nil }
        .contentShape(Rectangle())
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
            firstName: "",
            lastName: "",
            firstNameError: nil,
            lastNameError: nil,
            onFirstNameChange: {_ in},
            onLastNameChange: {_ in},
            onNextClick: {_, _ in}
        )
    }
}
