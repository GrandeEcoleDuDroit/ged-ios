import SwiftUI

struct SentMessageItem: View {
    let message: Message
    let showSeen: Bool
    let onClick: () -> Void
        
    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .trailing) {
                Button(action: onClick) {
                    MessageBubble(
                        text: message.content,
                        date: message.date,
                        backgroundColor: .gedPrimary,
                        textColor: .white,
                        dateColor: Color(UIColor.lightText)
                    )
                }
                .buttonStyle(ClickStyle())
                .clipShape(.rect(cornerRadius: 24))
                
                if showSeen {
                    Text(stringResource(.seen))
                        .foregroundStyle(.gray)
                        .font(.caption)
                        .padding(.trailing, Dimens.smallMediumPadding)
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
        .padding(.leading, Dimens.veryExtraLargePadding)
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
}

struct ReceiveMessageItem: View {
    let message: Message
    let profilePictureUrl: String?
    let displayProfilePicture: Bool
    let onLongClick: () -> Void
    let onInterlocutorProfilePictureClick: () -> Void
    
    var body: some View {
        HStack(alignment: .bottom) {
            if displayProfilePicture {
                ProfilePicture(url: profilePictureUrl, scale: 0.3)
                    .onTapGesture(perform: onInterlocutorProfilePictureClick)
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
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                onLongClick()
            }
        }
        .padding(.trailing, Dimens.veryExtraLargePadding)
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
        .padding(.horizontal, Dimens.mediumPadding)
        .background(backgroundColor)
        .clipShape(.rect(cornerRadius: 24))
    }
}

struct MessageInput: View {
    @Binding var text: String
    let onTextChange: (String) -> Void
    let onSendClick: () -> Void
    
    var body: some View {
        HStack(alignment: .center) {
            TextField(
                "",
                text: $text,
                prompt: messagePlaceholder,
                axis: .vertical
            )
            .lineLimit(6)
            .padding(.vertical, Dimens.smallPadding)
            .onChange(of: text, perform: onTextChange)
            
            if !text.isBlank() {
                Button(
                    action: onSendClick,
                    label: {
                        Image(systemName: "paperplane.fill")
                            .resizable()
                            .frame(width: 20, height: 20)
                    }
                )
                .padding(.horizontal, Dimens.mediumPadding)
                .padding(.vertical, 8)
                .background(.gedPrimary)
                .foregroundStyle(.white)
                .clipShape(.rect(cornerRadius: 20))
            }
        }
        .padding(.leading, Dimens.mediumPadding)
        .padding(.trailing, Dimens.smallPadding)
        .padding(.vertical, Dimens.extraSmallPadding)
        .background(.chatInputBackground)
        .clipShape(.rect(cornerRadius: 30))
        .padding(.bottom, Dimens.smallPadding)
    }
    
    var messagePlaceholder: Text {
        if #available(iOS 17.0, *) {
            Text(stringResource(.messagePlaceholder))
                .foregroundStyle(.onSurfaceVariant)
        } else {
            Text(stringResource(.messagePlaceholder))
                .foregroundColor(.onSurfaceVariant)
        }
    }
}

struct NewMessageIndicator: View {
    let onClick: () -> Void
    
    var body: some View {
        VStack {
            Button(action: onClick) {
                Text(stringResource(.newMessage))
                    .foregroundStyle(.black)
                    .font(.footnote)
                    .fontWeight(.medium)
                    .padding(.horizontal, Dimens.largePadding)
                    .padding(.vertical, Dimens.smallMediumPadding)
                    .background(.white)
                    .clipShape(ShapeDefaults.small)
                    .shadow(radius: 10, x: 0, y: 0)
            }
        }
    }
}

struct MessageBlockedUserIndicator: View {
    let onDeleteChatClick: () -> Void
    let onUnblockUserClick: () -> Void
    
    var body: some View {
        VStack(spacing: Dimens.mediumPadding) {
            VStack(spacing: Dimens.smallPadding) {
                Text(stringResource(.blockedUser))
                    .font(.titleSmall)
                
                Text(stringResource(.chatBlockedUserIndicatorText))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.informationText)
                    .font(.bodySmall)
            }
                
            HStack {
                Button(stringResource(.delete)) {
                    onDeleteChatClick()
                }
                .foregroundStyle(.red)
                .frame(maxWidth: .infinity, alignment: .center)
                
                Button(stringResource(.unblock)) {
                    onUnblockUserClick()
                }
                .foregroundStyle(.gedPrimary)
                .frame(maxWidth: .infinity, alignment: .center)
            }.frame(maxWidth: .infinity, alignment: .center)
        }
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 40) {
            ReceiveMessageItem(
                message: messageFixture,
                profilePictureUrl: nil,
                displayProfilePicture: true,
                onLongClick: {},
                onInterlocutorProfilePictureClick: {}
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
                message: messageFixture,
                showSeen: true,
                onClick: {}
            )
            
            NewMessageIndicator(onClick: {})
            
            MessageInput(
                text: .constant(""),
                onTextChange: { _ in },
                onSendClick: {}
            )
            
            MessageBlockedUserIndicator(
                onDeleteChatClick: {},
                onUnblockUserClick: {}
            )
        }
        .padding(.horizontal)
    }
}
