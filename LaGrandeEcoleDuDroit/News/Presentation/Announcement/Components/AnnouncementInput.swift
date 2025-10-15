import SwiftUI

struct AnnouncementInput: View {
    let title: String
    let content: String
    let onTitleChange: (String) -> Void
    let onContentChange: (String) -> Void
    var focusState: FocusState<Field?>.Binding
    
    var body: some View {
        VStack(spacing: GedSpacing.medium) {
            AnnouncementTitleInput(
                title: title,
                onTitleChange: onTitleChange,
                focusState: focusState
            )
            
            AnnouncementContentInput(
                content: content,
                onContentChange: onContentChange,
                focusState: focusState
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

private struct AnnouncementTitleInput: View {
    let title: String
    let onTitleChange: (String) -> Void
    var focusState: FocusState<Field?>.Binding

    var body: some View {
        TextField(
            getString(.title),
            text: Binding(
                get: { title },
                set: onTitleChange
            ),
            axis: .vertical
        )
        .font(.titleMedium)
        .fontWeight(.semibold)
        .focused(focusState, equals: .title)
    }
}

private struct AnnouncementContentInput: View {
    let content: String
    let onContentChange: (String) -> Void
    var focusState: FocusState<Field?>.Binding

    var body: some View {
        TextField(
            getString(.content),
            text: Binding(
                get: { content },
                set: onContentChange
            ),
            axis: .vertical
        )
        .font(.bodyMedium)
        .focused(focusState, equals: .content)
    }
}

#Preview {
    @FocusState var focusState: Field?
    
    AnnouncementInput(
        title: "",
        content: "",
        onTitleChange: {_ in },
        onContentChange: {_ in },
        focusState: $focusState
    )
    .padding(GedSpacing.medium)
}
