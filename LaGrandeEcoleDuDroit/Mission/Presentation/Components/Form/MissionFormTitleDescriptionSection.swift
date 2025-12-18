import SwiftUI

struct MissionFormTitleDescriptionSection: View {
    @Binding var title: String
    @Binding var description: String
    let onTitleChange: (String) -> Void
    let onDescriptionChange: (String) -> Void
    
    var body: some View {
        VStack(spacing: Dimens.mediumPadding) {
            TransparentTextField(
                stringResource(.title),
                text: $title,
            )
            .font(MissionUtilsPresentation.titleFont)
            .onChange(of: title, perform: onTitleChange)
            
            TransparentTextField(
                stringResource(.missionDescriptionField),
                text: $description,
            )
            .font(MissionUtilsPresentation.descriptionFont)
            .lineLimit(4...)
            .onChange(of: description, perform: onDescriptionChange)
        }
    }
}

#Preview {
    MissionFormTitleDescriptionSection(
        title: .constant(""),
        description: .constant(""),
        onTitleChange: { _ in },
        onDescriptionChange: { _ in }
    )
    .environment(\.managedObjectContext, GedDatabaseContainer.preview.container.viewContext)
}
