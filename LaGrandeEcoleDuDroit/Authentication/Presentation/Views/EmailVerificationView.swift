import SwiftUI

struct EmailVerificationView: View {
    @EnvironmentObject private var registrationViewModel: RegistrationViewModel
    @State private var isValid = false
    @State private var isAnimating = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: GedSpacing.medium) {
            Text(
                getString(
                    gedString: GedString.email_verification_explanation,
                    registrationViewModel.email
                )
            ).font(.title3)
            
            if case .error(let message) = registrationViewModel.registrationState {
                HStack {
                    Image(systemName: "exclamationmark.octagon")
                    Text(message)
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
                .foregroundStyle(.gedPrimary)
            
            Spacer()
            
            HStack {
                Spacer()
                Button(
                    action: {
                        Task { await registrationViewModel.checkVerifiedEmail() }
                    },
                    label: {
                        Text(getString(gedString: GedString.next))
                            .font(.title2)
                    }
                )
            }.padding()
        }
        .task {
            await registrationViewModel.sendVerificationEmail()
        }
        .navigationTitle(getString(gedString: GedString.email_verification_title))
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .navigationBarBackButtonHidden(true)
        .padding()
    }
}

struct EmailVerificationView_Previews: PreviewProvider {
    static var previews: some View {
        let registrationViewModel = DependencyContainer.shared.mockRegistrationViewModel
        registrationViewModel.email = "example@email.com"
        
        return EmailVerificationView()
            .environmentObject(registrationViewModel)
    }
}
