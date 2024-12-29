import SwiftUI

struct FirstRegistrationView: View {
    @EnvironmentObject private var registrationViewModel: RegistrationViewModel
    @EnvironmentObject private var coordinator: AuthenticationNavigationCoordinator
    @State private var inputFocused: InputField?
    @State private var isValidNameInputs = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: GedSpacing.medium) {
            Text(getString(.enterFirstNameAndLastName))
                .font(.title3)
            
            FocusableOutlinedTextField(
                title: getString(.firstName),
                text: $registrationViewModel.firstName,
                defaultFocusValue: InputField.firstName,
                inputFocused: $inputFocused
            )
            
            FocusableOutlinedTextField(
                title: getString(.lastName),
                text: $registrationViewModel.lastName,
                defaultFocusValue: InputField.lastName,
                inputFocused: $inputFocused
            )
         
            Spacer()
            
            HStack {
                Spacer()
                
                NavigationLink(value: AuthenticationScreen.secondRegistration) {
                    if registrationViewModel.nameInputsNotEmpty() {
                        Text(getString(.next))
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundStyle(.gedPrimary)
                    } else {
                        Text(getString(.next))
                            .font(.title2)
                            .fontWeight(.medium)
                    }
                }
                .disabled(!registrationViewModel.nameInputsNotEmpty())
                
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .contentShape(Rectangle())
        .padding()
        .onAppear { registrationViewModel.resetState() }
        .onTapGesture { inputFocused = nil }
        .navigationBarTitleDisplayMode(.inline)
        .registrationToolbar(step: 1, maxStep: 3)
        .navigationDestination(for: AuthenticationScreen.self) { screen in
            if case .secondRegistration = screen {
                SecondRegistrationView()
                    .environmentObject(registrationViewModel)
                    .environmentObject(coordinator)
            }
        }
    }
}

#Preview {
    NavigationStack {
        FirstRegistrationView()
            .environmentObject(DependencyContainer.shared.mockRegistrationViewModel)
            .environmentObject(AuthenticationNavigationCoordinator())
    }
}
