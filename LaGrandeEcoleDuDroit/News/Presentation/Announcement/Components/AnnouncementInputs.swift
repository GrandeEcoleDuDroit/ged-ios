import SwiftUI

struct AnnouncementInputs: View {
    @Binding var title: String
    @Binding var content: String
    let onTitleChange: (String) -> Void
    let onContentChange: (String) -> Void
    var focusState: FocusState<AnnouncementFocusField?>
    
    var body: some View {
        VStack(spacing: Dimens.mediumPadding) {
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
        .font(.titleMedium)
        .fontWeight(.semibold)
        .onChange(of: title, perform: onTitleChange)
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
        .scrollDismissesKeyboard(.interactively)
        .font(.bodyMedium)
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
    .padding(Dimens.mediumPadding)
}
