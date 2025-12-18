import SwiftUI

struct FirstRegistrationDestination: View {
    let onNextClick: (String, String) -> Void
     
    @StateObject private var viewModel = AuthenticationMainThreadInjector.shared.resolve(FirstRegistrationViewModel.self)
    
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
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Dimens.mediumPadding) {
                    Text(stringResource(.enterNames))
                        .font(.title3)
                    
                    OutlinedTextField(
                        stringResource(.firstName),
                        text: $firstName,
                        errorMessage: firstNameError
                    )
                    .onChange(of: firstName, perform: onFirstNameChange)
                    
                    OutlinedTextField(
                        stringResource(.lastName),
                        text: $lastName,
                        errorMessage: lastNameError
                    )
                    .onChange(of: lastName, perform: onLastNameChange)
                }
                .padding(.horizontal)
            }
            .scrollIndicators(.hidden)
            .scrollDismissesKeyboard(.interactively)
            
            Spacer()
            
            Button(action: { onNextClick(firstName, lastName)}) {
                Text(stringResource(.next))
                    .foregroundStyle(.gedPrimary)
            }
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(stringResource(.registration))
    }
}

#Preview {
    NavigationStack {
        FirstRegistrationView(
            firstName: .constant(""),
            lastName: .constant(""),
            firstNameError: nil,
            lastNameError: nil,
            onFirstNameChange: {_ in },
            onLastNameChange: {_ in },
            onNextClick: {_, _ in}
        )
        .background(.appBackground)
    }
    .environment(\.managedObjectContext, GedDatabaseContainer.preview.container.viewContext)
}
