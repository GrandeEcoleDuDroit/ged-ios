import SwiftUI

struct FirstRegistrationView: View {
    @EnvironmentObject private var registrationViewModel: RegistrationViewModel
    @State private var inputFocused: InputField?
    @State private var isValidNameInputs = false
    private let firstNameTextFieldTitle = getString(gedString: GedString.firstName)
    private let lastNameTextFieldTitle = getString(gedString: GedString.lastName)
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(alignment: .leading, spacing: GedSpacing.medium) {
            Text(getString(gedString: GedString.enter_first_name_and_last_name))
                .font(.title2)
            
            FocusableOutlinedTextField(
                title: firstNameTextFieldTitle,
                text: $registrationViewModel.firstName,
                defaultFocusValue: InputField.firstName,
                inputFocused: $inputFocused
            )
            
            FocusableOutlinedTextField(
                title: lastNameTextFieldTitle,
                text: $registrationViewModel.lastName,
                defaultFocusValue: InputField.lastName,
                inputFocused: $inputFocused
            )
            
            if case .error(let message) = registrationViewModel.registrationState {
                Text(message).foregroundColor(.red)
            }
            
            Spacer()
            
            HStack {
                Spacer()
                Button(
                    action: {
                        isValidNameInputs = registrationViewModel.validateNameInputs()
                    },
                    label: {
                        Text(getString(gedString: GedString.next))
                            .font(.title2)
                    }
                ).overlay {
                    NavigationLink(
                        destination: SecondRegistrationView().environmentObject(registrationViewModel),
                        isActive: $isValidNameInputs
                    ) {
                        EmptyView()
                    }
                }
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color(UIColor.systemBackground))
        .padding()
        .onAppear {
            registrationViewModel.resetState()
        }
        .onTapGesture {
            inputFocused = nil
        }
        .registrationToolbar(step: 1, maxStep: 3)
    }
}

#Preview {
    FirstRegistrationView()
        .environmentObject(DependencyContainer.shared.mockRegistrationViewModel)
}
