import SwiftUI

struct FirstRegistrationView: View {
    @StateObject private var registrationViewModel = RegistrationViewModel()
    @State private var inputFocused: InputField?
    private let titleFirstNameTextField = getString(gedString: GedString.firstName)
    private let titleLastNameTextField = getString(gedString: GedString.lastName)
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: GedSpacing.medium) {
                Text(getString(gedString: GedString.enter_first_name_and_last_name))
                    .font(.title2)
                
                FocusableOutlinedTextField(
                    title: titleFirstNameTextField,
                    text: $registrationViewModel.firstName,
                    defaultFocusValue: InputField.firstName,
                    inputFocused: $inputFocused
                )
                
                FocusableOutlinedTextField(
                    title: titleLastNameTextField,
                    text: $registrationViewModel.lastName,
                    defaultFocusValue: InputField.lastName,
                    inputFocused: $inputFocused
                )
                
                Spacer()
                HStack {
                    Spacer()
                    NavigationLink(destination: {}) {
                        Text(getString(gedString: GedString.next))
                            .tint(Color(GedColor.primary))
                            .font(.title3)
                    }
                }
                .padding()
            }
            .navigationTitle(getString(gedString: GedString.registration))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(Color(UIColor.systemBackground))
            .padding()
            .onTapGesture {
                inputFocused = nil
            }
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    BackButton(text: getString(gedString: GedString.back), action: {
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
}
