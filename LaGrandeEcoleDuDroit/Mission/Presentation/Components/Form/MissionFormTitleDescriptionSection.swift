import SwiftUI

struct MissionFormTitleDescriptionSection: View {
    @Binding var title: String
    @Binding var description: String
    let onTitleChange: (String) -> Void
    let onDescriptionChange: (String) -> Void
    
    var body: some View {
        VStack(spacing: DimensResource.mediumPadding) {
            TransparentTextField(
                stringResource(.title),
                text: $title,
            )
            .font(MissionUtilsPresentation.titleFont)
            .fontWeight(.semibold)
            .onChange(of: title, perform: onTitleChange)
            
            TransparentTextField(
                stringResource(.missionDescriptionField),
                text: $description,
            )
            .font(MissionUtilsPresentation.contentFont)
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
