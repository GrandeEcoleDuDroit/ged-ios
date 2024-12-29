import SwiftUI

struct SecondRegistrationView: View {
    @EnvironmentObject private var registrationViewModel: RegistrationViewModel
    @EnvironmentObject private var coordinator: AuthenticationNavigationCoordinator
    
    var body: some View {
        VStack(alignment: .leading, spacing: GedSpacing.medium) {
            Text(getString(.selectSchoolLevel))
                .font(.title3)
            
            HStack {
                Text(getString(.level))
                
                Spacer()
                
                Picker(
                    getString(.selectSchoolLevel),
                    selection: $registrationViewModel.schoolLevel
                ) {
                    ForEach(registrationViewModel.schoolLevels, id: \.self) { level in
                        Text(level)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color.black, lineWidth: 0.5)
            )
            
            Spacer()
            
            HStack {
                Spacer()
                NavigationLink(value: AuthenticationScreen.thirdRegistration) {
                    Text(getString(.next))
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundStyle(.gedPrimary)
                }
                
            }
            .padding()
        }
        .navigationDestination(for: AuthenticationScreen.self) { screen in
            if case .thirdRegistration = screen {
                ThirdRegistrationView()
                    .environmentObject(registrationViewModel)
                    .environmentObject(coordinator)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .contentShape(Rectangle())
        .navigationBarTitleDisplayMode(.inline)
        .padding()
        .onAppear { registrationViewModel.resetState() }
        .registrationToolbar(step: 2, maxStep: 3)
    }
}

#Preview {
    NavigationStack {
        SecondRegistrationView()
            .environmentObject(DependencyContainer.shared.mockRegistrationViewModel)
            .environmentObject(AuthenticationNavigationCoordinator())
    }
}
