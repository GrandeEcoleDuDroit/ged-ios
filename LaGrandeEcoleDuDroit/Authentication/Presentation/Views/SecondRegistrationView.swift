import SwiftUI

struct SecondRegistrationView: View {
    @EnvironmentObject private var registrationViewModel: RegistrationViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(alignment: .leading, spacing: GedSpacing.medium) {
            Text(getString(gedString: GedString.select_school_level))
                .font(.title2)
            
            HStack {
                Text(getString(gedString: GedString.level))
                
                Spacer()
                
                Picker(
                    getString(gedString: GedString.select_school_level),
                    selection: $registrationViewModel.schoolLevel
                ) {
                    ForEach(registrationViewModel.schoolLevels, id: \.self) { level in
                        Text(level)
                    }
                    
                }
            }
            .padding([.horizontal], 20)
            .padding([.vertical], 10)
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color.black, lineWidth: 0.5)
            )
            
            Spacer()
            
            HStack {
                Spacer()
                NavigationLink(
                    destination: ThirdRegistrationView()
                        .environmentObject(registrationViewModel)
                ) {
                    Text(getString(gedString: GedString.next))
                        .font(.title2)
                }
            }.padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding()
        .onAppear {
            registrationViewModel.resetState()
        }
        .registrationToolbar(step: 2, maxStep: 3)
    }
}

#Preview {
    SecondRegistrationView()
        .environmentObject(DependencyContainer.shared.mockRegistrationViewModel)
}
