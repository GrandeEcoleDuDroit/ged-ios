import SwiftUI

struct SecondRegistrationView: View {
    @EnvironmentObject private var registrationViewModel: RegistrationViewModel
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
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
                .tint(.black)
                
                Spacer()
                
                HStack {
                    Spacer()
                    NavigationLink(
                        destination: ThirdRegistrationView()
                            .environmentObject(registrationViewModel)
                    ) {
                        Text(getString(gedString: GedString.next))
                            .tint(Color(GedColor.primary))
                            .font(.title2)
                    }
                }.padding()
            }
            .navigationTitle(getString(gedString: GedString.registration))
            .navigationBarTitleDisplayMode(.inline)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding()
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    BackButton(action: {
                        presentationMode.wrappedValue.dismiss()
                    })
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Text(getString(gedString: GedString.registration_step, 2, registrationViewModel.maxStep))
                        .foregroundStyle(.gray)
                }
                
            }
        }.navigationBarBackButtonHidden()
    }
}

#Preview {
    SecondRegistrationView()
        .environmentObject(RegistrationViewModel())
}
