import SwiftUI

struct EmailVerificationView: View {
    @EnvironmentObject private var registrationViewModel: RegistrationViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var isValid = false
    @State private var isAnimating = false
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: GedSpacing.medium) {
                Text(
                    getString(
                        gedString: GedString.email_verification_explanation,
                        registrationViewModel.email
                    )
                ).font(.title3)
                
                if registrationViewModel.errorMessage != nil {
                    HStack {
                        Image(systemName: "exclamationmark.octagon")
                        Text(registrationViewModel.errorMessage!)
                    }.foregroundStyle(Color.red)
                }
                
                Image(systemName: "envelope.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(isAnimating ? 0.35 : 0.3)
                    .onAppear() {
                        withAnimation(.easeInOut(duration: 1.3).repeatForever(autoreverses: true)) {
                            isAnimating = true
                        }
                    }
                    .foregroundStyle(Color(GedColor.primary))
                
                Spacer()
                
                HStack {
                    Spacer()
                    NavigationLink(
                        destination: EmailVerificationView(),
                        isActive: $registrationViewModel.isEmailVerified
                    ) {
                        Button(action: {
                            registrationViewModel.checkVerifiedEmail()
                        }) {
                            Text(getString(gedString: GedString.next))
                                .tint(Color(GedColor.primary))
                                .font(.title2)
                        }
                    }
                }
                .padding()
            }
            .onAppear {
                registrationViewModel.resetErrorMessage()
                registrationViewModel.sendVerificationEmail()
            }
            .navigationTitle(getString(gedString: GedString.email_verification_title))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding()
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    BackButton(text: "", action: {
                        presentationMode.wrappedValue.dismiss()
                    })
                }
            }
            
        }.navigationBarBackButtonHidden()
    }
}

struct EmailVerificationView_Previews: PreviewProvider {
    static var previews: some View {
        let registrationViewModel = RegistrationViewModel()
        registrationViewModel.email = "example@email.com"
        
        return EmailVerificationView()
            .environmentObject(registrationViewModel)
    }
}
