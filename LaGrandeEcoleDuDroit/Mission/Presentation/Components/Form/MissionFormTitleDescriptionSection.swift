import SwiftUI

struct MissionFormTitleDescriptionSection: View {
    let title: String
    let description: String
    let onTitleChange: (String) -> String
    let onDescriptionChange: (String) -> String
    
    var body: some View {
        VStack(spacing: Dimens.mediumPadding) {
            TransparentTextField(
                initialText: title,
                onTextChange: onTitleChange,
                placeHolder: stringResource(.title)
            )
            .font(MissionUtilsPresentation.titleFont)
            
            TransparentTextField(
                initialText: description,
                onTextChange: onDescriptionChange,
                placeHolder: stringResource(.missionDescriptionField),
            )
            .font(MissionUtilsPresentation.descriptionFont)
            .lineLimit(4...)
        }
    }
}

#Preview {
    MissionFormTitleDescriptionSection(
        title: "",
        description: "",
        onTitleChange: { _ in "" },
        onDescriptionChange: { _ in "" }
    )
    .environment(\.managedObjectContext, GedDatabaseContainer.preview.container.viewContext)
}
