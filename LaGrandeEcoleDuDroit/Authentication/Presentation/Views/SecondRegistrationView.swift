import SwiftUI

struct SecondRegistrationView: View {
    @StateObject private var registrationViewModel = RegistrationViewModel()
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: GedSpacing.medium) {
                Text(getString(gedString: GedString.select_school_level))
                    .font(.title2)
                
                Picker(
                    getString(gedString: GedString.select_school_level),
                    selection: $registrationViewModel.schoolLevel
                ) {
                    ForEach(registrationViewModel.schoolLevels, id: \.self) { level in
                        Text(level)
                    }
                    
                }
                .pickerStyle(SegmentedPickerStyle())
                .background(Color(.lightGray).opacity(0.1))
                .tint(.black)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                
                Spacer()
                
                HStack {
                    Spacer()
                    NavigationLink(destination: {}) {
                        Text(getString(gedString: GedString.next))
                            .tint(Color(GedColor.primary))
                            .font(.title2)
                    }
                }
                .padding()
            }
            .navigationTitle(getString(gedString: GedString.registration)).navigationBarTitleDisplayMode(.inline)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(Color(UIColor.systemBackground))
            .padding()
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    BackButton(text: "", action: {
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
}
