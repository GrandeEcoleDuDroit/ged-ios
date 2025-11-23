import SwiftUI

struct MissionFormTitleDescriptionSection: View {
    let title: String
    let description: String
    let onTitleChange: (String) -> Void
    let onDescriptionChange: (String) -> Void
    
    var body: some View {
        VStack(spacing: Dimens.mediumPadding) {
            TextField(
                "",
                text: Binding(
                    get: { title },
                    set: onTitleChange
                ),
                prompt: Text(stringResource(.title))
                    .foregroundColor(.onSurfaceVariant),
                axis: .vertical
            )
            .font(.title)
            
            TextField(
                "",
                text: Binding(
                    get: { description },
                    set: onDescriptionChange
                ),
                prompt: Text(stringResource(.missionDescriptionField))
                    .foregroundColor(.onSurfaceVariant),
                axis: .vertical
            )
            .lineLimit(4...)
        }
    }
}

#Preview {
    MissionFormTitleDescriptionSection(
        title: "",
        description: "",
        onTitleChange: { _ in },
        onDescriptionChange: { _ in }
    )
}
