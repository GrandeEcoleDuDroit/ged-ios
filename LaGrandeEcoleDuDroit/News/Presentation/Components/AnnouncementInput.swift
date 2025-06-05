import SwiftUI

struct AnnouncementInput: View {
    @Binding var title: String
    @Binding var content: String
    @Binding var inputFieldFocused: InputField?
    let onTitleChange: (String) -> Void
    let onContentChange: (String) -> Void
    
    var body: some View {
        VStack(spacing: GedSpacing.medium) {
            AnnouncementTitleInput(
                title: $title,
                onTitleChange: onTitleChange,
                inputFieldFocused: $inputFieldFocused
            )
            
            AnnouncementContentInput(
                content: $content,
                onContentChange: onContentChange,
                inputFieldFocused: $inputFieldFocused
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

private struct AnnouncementTitleInput: View {
    @Binding var title: String
    let onTitleChange: (String) -> Void
    @Binding var inputFieldFocused: InputField?
    @FocusState private var focusedField: InputField?

    var body: some View {
        TextField(
            getString(.title),
            text: $title,
            axis: .vertical
        )
        .font(.title3)
        .fontWeight(.semibold)
        .focused($focusedField, equals: InputField.title)
        .onChange(of: title) { newValue in
            if newValue.count <= 300 {
                onTitleChange(newValue)
            } else {
                title = String(title.prefix(300))
            }
        }
        .onChange(of: inputFieldFocused) { newValue in
            focusedField = newValue
        }
    }
}

private struct AnnouncementContentInput: View {
    @Binding var content: String
    let onContentChange: (String) -> Void
    @Binding var inputFieldFocused: InputField?
    @FocusState private var focusedField: InputField?
    
    var body: some View {
        TextField(
            getString(.content),
            text: $content,
            axis: .vertical
        )
        .focused($focusedField, equals: InputField.content)
        .onChange(of: content) { newValue in
            if newValue.count <= 2000 {
                onContentChange(newValue)
            } else {
                content = String(content.prefix(2000))
            }
        }
        .onChange(of: inputFieldFocused) { newValue in
            focusedField = newValue
        }
    }
}

#Preview {
    AnnouncementInput(
        title: .constant(""),
        content: .constant(""),
        inputFieldFocused: .constant(nil),
        onTitleChange: {_ in },
        onContentChange: {_ in }
    )
    .padding(GedSpacing.medium)
}
