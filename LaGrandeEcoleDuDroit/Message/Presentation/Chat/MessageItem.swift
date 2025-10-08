import SwiftUI

struct SentMessageItem: View {
    let message: Message
    let showSeen: Bool
    let onClick: () -> Void
        
    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .trailing) {
                Clickable(action: onClick) {
                    MessageBubble(
                        text: message.content,
                        date: message.date,
                        backgroundColor: .gedPrimary,
                        textColor: .white,
                        dateColor: Color(UIColor.lightText)
                    )
                }
                .clipShape(.rect(cornerRadius: 24))
                
                if showSeen {
                    Text(getString(.seen))
                        .foregroundStyle(.gray)
                        .font(.caption)
                        .padding(.trailing, GedSpacing.smallMedium)
                }
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            
            switch message.state {
                case .sending:
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
        .padding(.leading, GedSpacing.veryExtraLarge)
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
}

struct ReceiveMessageItem: View {
    let message: Message
    let profilePictureUrl: String?
    let displayProfilePicture: Bool
    let onLongClick: () -> Void
    
    var body: some View {
        HStack(alignment: .bottom) {
            if displayProfilePicture {
                ProfilePicture(url: profilePictureUrl, scale: 0.3)
            }
            else {
                ProfilePicture(url: nil, scale: 0.3)
                    .hidden()
            }
            
            MessageBubble(
                text: message.content,
                date: message.date,
                backgroundColor: .chatInputBackground,
                textColor: .primary,
                dateColor: .gray
            ).onLongPressGesture {
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
                onLongClick()
            }
        }
        .padding(.trailing, GedSpacing.veryExtraLarge)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct MessageBubble: View {
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
        .padding(.vertical, 10)
        .padding(.horizontal, GedSpacing.medium)
        .background(backgroundColor)
        .clipShape(.rect(cornerRadius: 24))
    }
}

struct MessageInput: View {
    let text: String
    let onTextChange: (String) -> Void
    let onSendClick: () -> Void
    
    var body: some View {
        HStack(alignment: .center) {
            TextField(
                "",
                text: Binding(
                    get: { text },
                    set: onTextChange
                ),
                prompt: messagePlaceholder,
                axis: .vertical
            )
            .lineLimit(6)
            .padding(.vertical, GedSpacing.small)
            
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
                .padding(.vertical, 8)
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
    let onClick: () -> Void
    
    var body: some View {
        Clickable(action: onClick) {
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
        }
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
                    onLongClick: {}
                )
                
                ReceiveMessageItem(
                    message: messageFixture2,
                    profilePictureUrl: nil,
                    displayProfilePicture: true,
                    onLongClick: {}
                )
                
                SentMessageItem(
                    message: messageFixture.copy { $0.state = .error },
                    showSeen: false,
                    onClick: {}
                )
                
                SentMessageItem(
                    message: messageFixture.copy { $0.state = .sending },
                    showSeen: false,
                    onClick: {}
                )
                
                SentMessageItem(
                    message: messageFixture2,
                    showSeen: true,
                    onClick: {}
                )
            }
            
            NewMessageIndicator(onClick: {})
        }

        MessageInput(
            text: "",
            onTextChange: { _ in },
            onSendClick: {}
        )
    }
    .padding(.top)
    .padding(.horizontal)
    .background(Color.background)
}
