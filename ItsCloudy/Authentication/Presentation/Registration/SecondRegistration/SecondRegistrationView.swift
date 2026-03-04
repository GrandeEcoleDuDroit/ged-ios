import SwiftUI

struct SecondRegistrationDestination: View {
    let firstName: String
    let lastName: String
    let onNextClick: (SchoolLevel) -> Void
    
    @StateObject private var viewModel = AuthenticationMainThreadInjector.shared.resolve(SecondRegistrationViewModel.self)
    
    var body: some View {
        SecondRegistrationView(
            firstName: firstName,
            lastName: lastName,
            schoolLevel: $viewModel.schoolLevel,
            schoolLevels: viewModel.schoolLevels,
            onNextClick: { onNextClick(viewModel.schoolLevel) }
        )
    }
}

private struct SecondRegistrationView: View {
    let firstName: String
    let lastName: String
    @Binding var schoolLevel: SchoolLevel
    let schoolLevels: [SchoolLevel]
    let onNextClick: () -> Void
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DimensResource.mediumPadding) {
                    Text(stringResource(.selectSchoolLevel))
                        .font(.title3)
                    
                    OutlinedSchoolLevelPicker(
                        schoolLevels: schoolLevels,
                        schoolLevel: $schoolLevel
                    )
                }
                .padding(.horizontal)
            }
            .scrollIndicators(.hidden)
            .scrollDismissesKeyboard(.interactively)
            
            Spacer()
            
            Button(action: onNextClick) {
                Text(stringResource(.next))
                    .foregroundStyle(.appPrimary)
            }
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(stringResource(.registration))
    }
}

private struct OutlinedSchoolLevelPicker: View {
    let schoolLevels: [SchoolLevel]
    @Binding var schoolLevel: SchoolLevel
    
    var body: some View {
        HStack {
            Text(stringResource(.level))
            
            Spacer()
            
            Picker(
                stringResource(.selectSchoolLevel),
                selection: $schoolLevel
            ) {
                ForEach(schoolLevels) { level in
                    Text(level.description).tag(level)
                }
            }
        }
        .padding(.horizontal, DimensResource.mediumPadding)
        .padding(.vertical, 10)
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .stroke(.outline, lineWidth: 1)
        )
    }
}

#Preview {
    NavigationStack {
        SecondRegistrationView(
            firstName: "",
            lastName: "",
            schoolLevel: .constant(SchoolLevel.level1),
            schoolLevels: SchoolLevel.all,
            onNextClick: {}
        )
        .background(.appBackground)
    }
    .environment(\.managedObjectContext, GedDatabaseContainer.preview.container.viewContext)
}
