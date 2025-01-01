import SwiftUI

struct SendMessageItem: View {
    @State var text: String
    @State var screenWidth: CGFloat
    
    init(text: String, screenWidth: CGFloat) {
        self.text = text
        self.screenWidth = screenWidth
    }
    
    var body: some View {
        ZStack {
            Text(text)
                .foregroundStyle(.white)
                .padding()
                .background(.gedPrimary)
                .clipShape(.rect(cornerRadius: 30))
                .frame(maxWidth: screenWidth / 1.5, alignment: .trailing)
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
}

struct ReceiveMessageItem: View {
    @State var text: String
    @State var screenWidth: CGFloat
    
    init(text: String, screenWidth: CGFloat) {
        self.text = text
        self.screenWidth = screenWidth
    }
    
    var body: some View {
        ZStack {
            Text(text)
                .foregroundStyle(.black)
                .padding()
                .background(.receiveMessageComponentBackground)
                .clipShape(.rect(cornerRadius: 30))
                .frame(maxWidth: screenWidth / 1.5, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct ChatInputField: View {
    @Binding var text: String
    @Binding var inputFocused: InputField?
    @FocusState private var focusedField: InputField?
    private var onSendClick: () -> Void
    private let maxCharacters = 1000
    
    init(
        text: Binding<String>,
        onSendClick: @escaping () -> Void,
        inputFocused: Binding<InputField?>
    ) {
        self._text = text
        self.onSendClick = onSendClick
        self._inputFocused = inputFocused
    }
    
    var body: some View {
        HStack(alignment: .center) {
            TextField(
                "",
                text: $text,
                prompt: messagePlaceholder,
                axis: .vertical
            )
            .padding(.vertical, GedSpacing.medium)
            .focused($focusedField, equals: InputField.chat)
            .simultaneousGesture(TapGesture().onEnded({
                inputFocused = InputField.chat
            }))
            
            if !text.isBlank {
                Button(
                    action: onSendClick,
                    label: {
                        Image(systemName: "paperplane.fill")
                            .resizable()
                            .frame(width: 20, height: 20)
                    }
                )
                .padding(.horizontal, GedSpacing.medium)
                .padding(.vertical, 10)
                .background(.gedPrimary)
                .foregroundStyle(.white)
                .clipShape(.rect(cornerRadius: 20))
            }
        }
        .padding(.leading, GedSpacing.medium)
        .padding(.trailing, GedSpacing.small)
        .background(.receiveMessageComponentBackground)
        .clipShape(.rect(cornerRadius: 30))
        .onChange(of: inputFocused) { newValue in
            focusedField = newValue
        }
    }
    
    var messagePlaceholder: Text {
        if #available(iOS 17.0, *) {
            Text(getString(.messagePlaceholder))
                .foregroundStyle(.gray)
        } else {
            Text(getString(.messagePlaceholder))
                .foregroundColor(.gray)
        }
    }
}

#Preview {
    struct ChatComponents_Previews: View {
        @State private var text: String = ""
        @State private var inputFocused: InputField? = nil
        
        var body: some View {
            ChatInputField(
                text: $text,
                onSendClick: {},
                inputFocused: $inputFocused
            )
        }
    }
    
    return ChatComponents_Previews()
}
