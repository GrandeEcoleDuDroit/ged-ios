import SwiftUI

struct SendMessageItem: View {
    private var text: String
    private var screenWidth: CGFloat
    private var state: MessageState
    private let date: Date
    
    init(
        text: String,
        screenWidth: CGFloat,
        state: MessageState,
        date: Date
    ) {
        self.text = text
        self.screenWidth = screenWidth
        self.state = state
        self.date = date
    }
    
    var body: some View {
        HStack(alignment: .bottom) {
            
            VStack(alignment: .trailing) {
                Text(text)
                    .foregroundStyle(.white)
                
                Text(date, style: .time)
                    .foregroundStyle(Color(UIColor.lightText))
                    .font(.caption)
            }
            .padding(.vertical,GedSpacing.smallMedium)
            .padding(.horizontal,GedSpacing.medium)
            .background(.gedPrimary)
            .clipShape(.rect(cornerRadius: 30))
            .frame(maxWidth: screenWidth / 1.5, alignment: .trailing)
            
            switch state {
                case .loading:
                    Image(systemName: "paperplane")
                        .resizable()
                        .foregroundColor(.gray)
                        .frame(width: 18, height: 18)
                case .error:
                    Image(systemName: "exclamationmark.circle")
                        .resizable()
                        .frame(width: 18, height: 18)
                        .foregroundColor(.red)
                default:
                    EmptyView()
            }
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
}

struct ReceiveMessageItem: View {
    private let text: String
    private let screenWidth: CGFloat
    private let displayProfilePicture: Bool
    private let profilePictureUrl: String?
    private let date: Date
    
    init(
        text: String,
        screenWidth: CGFloat,
        displayProfilePicture: Bool,
        profilePictureUrl: String?,
        date: Date
    ) {
        self.text = text
        self.screenWidth = screenWidth
        self.displayProfilePicture = displayProfilePicture
        self.profilePictureUrl = profilePictureUrl
        self.date = date
    }
    
    var body: some View {
        HStack(alignment: .bottom) {
            if displayProfilePicture {
                ProfilePicture(url: profilePictureUrl, scale: 0.3)
            }
            else {
                ProfilePicture(url: nil, scale: 0.3)
                    .hidden()
            }
            
            HStack(alignment: .bottom) {
                Text(text)
                    .foregroundStyle(.black)
                
                Text(date, style: .time)
                    .foregroundStyle(.gray)
                    .font(.caption)
            }
            .padding(.vertical, GedSpacing.smallMedium)
            .padding(.horizontal, GedSpacing.medium)
            .background(.receiveMessageComponent)
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
            .padding(.vertical, GedSpacing.smallMedium)
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
        .padding(.vertical, GedSpacing.verySmall)
        .background(.receiveMessageComponent)
        .clipShape(.rect(cornerRadius: 30))
        .padding(.bottom, GedSpacing.small)
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
            VStack {
                ScrollView {
                    ReceiveMessageItem(
                        text: "Received",
                        screenWidth: 375,
                        displayProfilePicture: false,
                        profilePictureUrl: nil,
                        date: Date.now
                    )
                    
                    ReceiveMessageItem(
                        text: announcementFixture.content,
                        screenWidth: 375,
                        displayProfilePicture: true,
                        profilePictureUrl: nil,
                        date: Date.now
                    )
                    
                    SendMessageItem(
                        text: "Sent",
                        screenWidth: 375,
                        state: .sent,
                        date: Date.now
                    )
                    
                    SendMessageItem(
                        text: "Loading",
                        screenWidth: 375,
                        state: .loading,
                        date: Date.now
                    )
                    
                    SendMessageItem(
                        text: "Error",
                        screenWidth: 375,
                        state: .error,
                        date: Date.now
                    )
                    
                    SendMessageItem(
                        text: announcementFixture.content,
                        screenWidth: 375,
                        state: .sent,
                        date: Date.now
                    )
                }
                
                
                ChatInputField(
                    text: $text,
                    onSendClick: {},
                    inputFocused: $inputFocused
                )
            }
            .padding()
        }
    }
    
    return ChatComponents_Previews()
}
