import SwiftUI
import Combine

struct ChatDestination: View {
    let conversation: Conversation
    let onBackClick: () -> Void
    
    @StateObject private var viewModel: ChatViewModel
    @State private var showErrorAlert = false
    
    init(
        conversation: Conversation,
        onBackClick: @escaping () -> Void
    ) {
        self.conversation = conversation
        _viewModel = StateObject(
            wrappedValue: MessageInjection.shared.resolve(ChatViewModel.self, arguments: conversation)!
        )
        self.onBackClick = onBackClick
    }
    
    var body: some View {
        ChatView(
            conversation: conversation,
            messages: viewModel.uiState.messages.values.map(\.self).sorted { $0.date < $1.date },
            text: $viewModel.uiState.text,
            onSendMessagesClick: viewModel.sendMessage,
            onBackClick: onBackClick,
            loadMoreMessages: viewModel.loadMoreMessages
        )
        .navigationBarBackButtonHidden()
    }
}

private struct ChatView: View {
    let conversation: Conversation
    let messages: [Message]
    @Binding var text: String
    let onSendMessagesClick: () -> Void
    let onBackClick: () -> Void
    let loadMoreMessages: () -> Void
    
    @State private var inputFocused: Bool = false

    var body: some View {
        VStack(spacing: GedSpacing.medium) {
            MessageFeed(
                messages: messages,
                conversation: conversation,
                loadMoreMessages: loadMoreMessages
            )
            
            ChatInputField(
                text: $text,
                inputFocused: $inputFocused,
                onSendClick: onSendMessagesClick
            )
        }
        .padding(.horizontal)
        .contentShape(Rectangle())
        .onTapGesture {
            inputFocused = false
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                HStack {
                    Button(
                        action: onBackClick,
                        label: {
                            Image(systemName: "chevron.backward")
                                .fontWeight(.semibold)
                                .padding(.trailing)
                        }
                    )
                    
                    ProfilePicture(url: conversation.interlocutor.profilePictureFileName, scale: 0.4)
                    
                    Text(conversation.interlocutor.fullName)
                        .fontWeight(.medium)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ChatView(
            conversation: conversationFixture,
            messages: messagesFixture,
            text: .constant(""),
            onSendMessagesClick: {},
            onBackClick: {},
            loadMoreMessages: {}
        )
        .background(Color.background)
    }
}
