import SwiftUI

struct FirstRegistrationView: View {
    @EnvironmentObject private var registrationViewModel: RegistrationViewModel
    @State private var inputFocused: InputField?
    @State private var isValidNameInputs = false
    private let firstNameTextFieldTitle = getString(gedString: GedString.firstName)
    private let lastNameTextFieldTitle = getString(gedString: GedString.lastName)
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
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
                    Text(message)
                        .foregroundColor(.red)
                }
                
                Spacer()
                
                HStack {
                    Spacer()
                    NavigationLink(
                        destination: SecondRegistrationView().environmentObject(registrationViewModel),
                        isActive: $isValidNameInputs
                    ) {
                        Button(action: {
                            isValidNameInputs = registrationViewModel.validateNameInputs()
                        }) {
                            Text(getString(gedString: GedString.next))
                                .tint(Color(GedColor.primary))
                                .font(.title2)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle(getString(gedString: GedString.registration))
            .navigationBarTitleDisplayMode(.inline)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(Color(UIColor.systemBackground))
            .padding()
            .onTapGesture {
                inputFocused = nil
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    BackButton(action: {
                        presentationMode.wrappedValue.dismiss()
                    })
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Text(getString(gedString: GedString.registration_step, 1, registrationViewModel.maxStep))
                        .foregroundStyle(.gray)
                }
                
            }
        }.navigationBarBackButtonHidden()

    }
}

#Preview {
    FirstRegistrationView()
        .environmentObject(DependencyContainer.shared.registrationViewModel)
}
