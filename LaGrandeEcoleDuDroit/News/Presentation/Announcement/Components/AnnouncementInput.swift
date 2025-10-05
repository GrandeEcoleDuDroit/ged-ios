import SwiftUI

struct AnnouncementInput: View {
    let title: String
    let content: String
    @Binding var focusedInputField: InputField?
    let onTitleChange: (String) -> Void
    let onContentChange: (String) -> Void
    
    var body: some View {
        VStack(spacing: GedSpacing.medium) {
            AnnouncementTitleInput(
                title: title,
                onTitleChange: onTitleChange,
                focusedInputField: $focusedInputField
            )
            
            AnnouncementContentInput(
                content: content,
                onContentChange: onContentChange,
                focusedInputField: $focusedInputField
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

private struct AnnouncementTitleInput: View {
    let title: String
    let onTitleChange: (String) -> Void
    @Binding var focusedInputField: InputField?
    @FocusState private var focusedField: InputField?

    var body: some View {
        TextField(
            getString(.title),
            text: Binding(
                get: { title },
                set: onTitleChange
            ),
            axis: .vertical
        )
        .font(.title3)
        .fontWeight(.semibold)
        .focused($focusedField, equals: InputField.title)
        .onChange(of: focusedInputField) { newValue in
            focusedField = newValue
        }
    }
}

private struct AnnouncementContentInput: View {
    let content: String
    let onContentChange: (String) -> Void
    @Binding var focusedInputField: InputField?
    @FocusState private var focusedField: InputField?
    
    var body: some View {
        TextField(
            getString(.content),
            text: Binding(
                get: { content },
                set: onContentChange
            ),
            axis: .vertical
        )
        .focused($focusedField, equals: InputField.content)
        .onChange(of: focusedInputField) { newValue in
            focusedField = newValue
        }
    }
}

#Preview {
    AnnouncementInput(
        title: "",
        content: "",
        focusedInputField: .constant(nil),
        onTitleChange: {_ in },
        onContentChange: {_ in }
    )
    .padding(GedSpacing.medium)
}
