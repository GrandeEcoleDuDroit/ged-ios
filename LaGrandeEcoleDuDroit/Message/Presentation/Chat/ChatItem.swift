import SwiftUI

struct SendMessageItem: View {
    let message: Message
    let showSeen: Bool
    let screenWidth: CGFloat
    
    var body: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .trailing) {
                MessageText(
                    text: message.content,
                    date: message.date,
                    backgroundColor: .gedPrimary,
                    textColor: .white,
                    dateColor: Color(UIColor.lightText)
                )
                
                if showSeen {
                    Text(getString(.seen))
                        .foregroundStyle(.gray)
                        .font(.caption)
                        .padding(.trailing, GedSpacing.smallMedium)
                }
            }
            .frame(maxWidth: screenWidth / 1.5, alignment: .trailing)
            
            switch message.state {
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
    let message: Message
    let profilePictureUrl: String?
    let displayProfilePicture: Bool
    let screenWidth: CGFloat
    
    var body: some View {
        HStack(alignment: .bottom) {
            if displayProfilePicture {
                ProfilePicture(url: profilePictureUrl, scale: 0.3)
            }
            else {
                ProfilePicture(url: nil, scale: 0.3)
                    .hidden()
            }
            
            MessageText(
                text: message.content,
                date: message.date,
                backgroundColor: .chatInputBackground,
                textColor: .primary,
                dateColor: .gray
            )
            .frame(maxWidth: screenWidth / 1.5, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct MessageText: View {
    let text: String
    let date: Date
    let backgroundColor: Color
    let textColor: Color
    let dateColor: Color
    
    var body: some View {
        HStack(alignment: .bottom) {
            Text(text)
                .foregroundStyle(textColor)
            
            Text(date, style: .time)
                .foregroundStyle(dateColor)
                .font(.caption)
        }
        .padding(.vertical, GedSpacing.small)
        .padding(.horizontal, GedSpacing.medium)
        .background(backgroundColor)
        .clipShape(.rect(cornerRadius: 24))
    }
}

struct ChatInputField: View {
    @Binding var text: String
    @Binding var inputFocused: Bool
    @FocusState var focusedField: Bool
    let onSendClick: () -> Void
    
    private let maxCharacters = 1000
    
    var body: some View {
        HStack(alignment: .center) {
            TextField(
                "",
                text: $text,
                prompt: messagePlaceholder,
                axis: .vertical
            )
            .padding(.vertical, GedSpacing.small)
            .focused($focusedField, equals: inputFocused)
            .simultaneousGesture(TapGesture().onEnded({
                inputFocused = true
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
        .padding(.vertical, GedSpacing.extraSmall)
        .background(.chatInputBackground)
        .clipShape(.rect(cornerRadius: 30))
        .padding(.bottom, GedSpacing.small)
        .onChange(of: inputFocused) { newValue in
            focusedField = newValue
        }
    }
    
    var messagePlaceholder: Text {
        if #available(iOS 17.0, *) {
            Text(getString(.messagePlaceholder))
                .foregroundStyle(.chatInputForeground)
        } else {
            Text(getString(.messagePlaceholder))
                .foregroundColor(.chatInputForeground)
        }
    }
}

struct NewMessageIndicator: View {
    @Binding var isClicked: Bool
    let onClick: () -> Void
    var body: some View {
        ZStack {
            Text(getString(.newMessages))
                .foregroundStyle(.black)
                .font(.footnote)
                .fontWeight(.medium)
                .padding(.horizontal, GedSpacing.large)
                .padding(.vertical, GedSpacing.smallMedium)
        }
        .background(.white)
        .clipShape(.rect(cornerRadius: 8))
        .shadow(radius: 10, x: 0, y: 0)
        .onClick(isClicked: $isClicked, action: onClick)
    }
}

#Preview {
    VStack(spacing: GedSpacing.medium) {
        ZStack(alignment: .bottom) {
            ScrollView {
                ReceiveMessageItem(
                    message: messageFixture,
                    profilePictureUrl: nil,
                    displayProfilePicture: true,
                    screenWidth: 400
                )
                
                SendMessageItem(
                    message: messageFixture.with(state: .error),
                    showSeen: false,
                    screenWidth: 400
                )
                
                SendMessageItem(
                    message: messageFixture.with(state: .loading),
                    showSeen: false,
                    screenWidth: 400
                )
                
                SendMessageItem(
                    message: messageFixture2,
                    showSeen: true,
                    screenWidth: 400
                )
                
                ReceiveMessageItem(
                    message: messageFixture,
                    profilePictureUrl: nil,
                    displayProfilePicture: true,
                    screenWidth: 400
                )
                
                SendMessageItem(
                    message: messageFixture.with(state: .error),
                    showSeen: false,
                    screenWidth: 400
                )
                
                SendMessageItem(
                    message: messageFixture.with(state: .loading),
                    showSeen: false,
                    screenWidth: 400
                )
                
                SendMessageItem(
                    message: messageFixture2,
                    showSeen: true,
                    screenWidth: 400
                )
                
                ReceiveMessageItem(
                    message: messageFixture,
                    profilePictureUrl: nil,
                    displayProfilePicture: true,
                    screenWidth: 400
                )
                
                SendMessageItem(
                    message: messageFixture.with(state: .error),
                    showSeen: false,
                    screenWidth: 400
                )
                
                SendMessageItem(
                    message: messageFixture.with(state: .loading),
                    showSeen: false,
                    screenWidth: 400
                )
                
                SendMessageItem(
                    message: messageFixture2,
                    showSeen: true,
                    screenWidth: 400
                )
                
                ReceiveMessageItem(
                    message: messageFixture,
                    profilePictureUrl: nil,
                    displayProfilePicture: true,
                    screenWidth: 400
                )
                
                SendMessageItem(
                    message: messageFixture.with(state: .error),
                    showSeen: false,
                    screenWidth: 400
                )
                
                SendMessageItem(
                    message: messageFixture.with(state: .loading),
                    showSeen: false,
                    screenWidth: 400
                )
                
                SendMessageItem(
                    message: messageFixture2,
                    showSeen: true,
                    screenWidth: 400
                )
                
                ReceiveMessageItem(
                    message: messageFixture,
                    profilePictureUrl: nil,
                    displayProfilePicture: true,
                    screenWidth: 400
                )
                
                SendMessageItem(
                    message: messageFixture.with(state: .error),
                    showSeen: false,
                    screenWidth: 400
                )
                
                SendMessageItem(
                    message: messageFixture.with(state: .loading),
                    showSeen: false,
                    screenWidth: 400
                )
                
                SendMessageItem(
                    message: messageFixture2,
                    showSeen: true,
                    screenWidth: 400
                )
            }
            
            NewMessageIndicator(
                isClicked: .constant(false),
                onClick: {}
            )
        }

        ChatInputField(
            text: .constant(""),
            inputFocused: .constant(false),
            onSendClick: {}
        )
    }
    .padding(.top)
    .padding(.horizontal)
    .background(Color.background)
}
