import SwiftUI

struct FirstRegistrationView: View {
    @StateObject private var registrationViewModel: RegistrationViewModel = AuthenticationInjection.shared.resolve(RegistrationViewModel.self)
    @State private var inputFieldFocused: InputField?
    @State private var isValidNameInputs = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: GedSpacing.medium) {
            Text(getString(.enterFirstNameAndLastName))
                .font(.title3)
            
            FocusableOutlinedTextField(
                title: getString(.firstName),
                text: $registrationViewModel.firstName,
                inputField: InputField.firstName,
                inputFieldFocused: $inputFieldFocused
            )
            
            FocusableOutlinedTextField(
                title: getString(.lastName),
                text: $registrationViewModel.lastName,
                inputField: InputField.lastName,
                inputFieldFocused: $inputFieldFocused
            )
         
            Spacer()
            
            NavigationLink(
                destination: SecondRegistrationView()
                    .environmentObject(registrationViewModel)
            ) {
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
            .padding()
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding()
        .onAppear {
            registrationViewModel.resetSchoolLevel()
            registrationViewModel.resetState()
        }
        .contentShape(Rectangle())
        .onTapGesture { inputFieldFocused = nil }
        .registrationToolbar(step: 1, maxStep: 3)
    }
}

#Preview {
    let mockRegistrationViewModel = AuthenticationInjection.shared.resolveWithMock().resolve(RegistrationViewModel.self)!
    
    NavigationStack {
        FirstRegistrationView()
            .environmentObject(mockRegistrationViewModel)
            .environmentObject(CommonInjection.shared.resolve(NavigationCoordinator.self))
    }
}
