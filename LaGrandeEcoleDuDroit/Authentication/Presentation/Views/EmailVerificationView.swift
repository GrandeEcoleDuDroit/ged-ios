import SwiftUI

struct EmailVerificationView: View {
    @EnvironmentObject private var registrationViewModel: RegistrationViewModel
    @State private var isValid = false
    @State private var isAnimating = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: GedSpacing.medium) {
            Text(getString(.emailVerificationExplanationBegining))
                .font(.title3)
            
             + Text(registrationViewModel.email)
                .fontWeight(.medium)
                .font(.title3)
            
             + Text(getString(.emailVerificationExplanationEnd))
                .font(.title3)
            
            if case .error(let message) = registrationViewModel.registrationState {
                HStack {
                    Image(systemName: "exclamationmark.octagon")
                    Text(message)
                }
                .foregroundStyle(Color.red)
            }
            
            Image(systemName: "envelope.circle.fill")
                .resizable()
                .scaledToFit()
                .scaleEffect(isAnimating ? 0.4 : 0.35)
                .onAppear() {
                    withAnimation(.easeInOut(duration: 1.3).repeatForever(autoreverses: true)) {
                        isAnimating = true
                    }
                }
                .foregroundStyle(.gedPrimary)
                .frame(maxHeight: .infinity, alignment: .center)
            
            HStack {
                Button(
                    action: {
                        Task { await registrationViewModel.checkVerifiedEmail() }
                    },
                    label: {
                        Text(getString(.terminate))
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundStyle(.gedPrimary)
                    }
                )
                .padding()
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .task {
            await registrationViewModel.sendVerificationEmail()
        }
        .navigationTitle(getString(.emailVerificationTitle))
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .navigationBarBackButtonHidden(true)
        .padding()
    }
}

#Preview {
    NavigationStack {
        EmailVerificationView()
            .environmentObject(DependencyContainer.shared.mockRegistrationViewModel)
    }
}
