import SwiftUI

struct AnnouncementInputs: View {
    @Binding var title: String
    @Binding var content: String
    let onTitleChange: (String) -> Void
    let onContentChange: (String) -> Void
    var focusState: FocusState<AnnouncementFocusField?>
    
    var body: some View {
        VStack(spacing: DimensResource.smallMediumPadding) {
            AnnouncementTitleInput(
                title: $title,
                onTitleChange: onTitleChange,
                focusState: focusState
            )
            
            AnnouncementContentInput(
                content: $content,
                onContentChange: onContentChange,
                focusState: focusState
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

private struct AnnouncementTitleInput: View {
    @Binding var title: String
    let onTitleChange: (String) -> Void
    var focusState: FocusState<AnnouncementFocusField?>

    var body: some View {
        TransparentTextField(
            stringResource(.title),
            text: $title,
            focusState: focusState,
            field: .title
        )
        .font(AnnouncementUtilsPresentation.titleFont)
        .fontWeight(.semibold)
        .onChange(of: title, perform: onTitleChange)
        .padding(.leading, 5)
    }
}

private struct AnnouncementContentInput: View {
    @Binding var content: String
    let onContentChange: (String) -> Void
    var focusState: FocusState<AnnouncementFocusField?>

    var body: some View {
        TransparentTextFieldArea(
            stringResource(.content),
            text: $content,
            focusState: focusState,
            field: .content
        )
        .font(AnnouncementUtilsPresentation.contentFont)
        .scrollDismissesKeyboard(.interactively)
        .onChange(of: content, perform: onContentChange)
    }
}

#Preview {
    @FocusState var focusState: AnnouncementFocusField?
    
    AnnouncementInputs(
        title: .constant(""),
        content: .constant(""),
        onTitleChange: {_ in },
        onContentChange: {_ in },
        focusState: _focusState
    )
    .padding(DimensResource.mediumPadding)
}
