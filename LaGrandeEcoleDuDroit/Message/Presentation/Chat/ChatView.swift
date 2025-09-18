import SwiftUI
import Combine

struct ChatDestination: View {
    let conversation: Conversation
    let onBackClick: () -> Void
    let onInterlocutorClick: (User) -> Void
    
    @StateObject private var viewModel: ChatViewModel
    @State private var showErrorAlert = false
    @State private var errorMessage: String = ""
    
    init(
        conversation: Conversation,
        onBackClick: @escaping () -> Void,
        onInterlocutorClick: @escaping (User) -> Void
    ) {
        self.conversation = conversation
        _viewModel = StateObject(
            wrappedValue: MessageInjection.shared.resolve(ChatViewModel.self, arguments: conversation)!
        )
        self.onBackClick = onBackClick
        self.onInterlocutorClick = onInterlocutorClick
    }
    
    var body: some View {
        ChatView(
            conversation: conversation,
            messages: viewModel.uiState.messages.values.map(\.self).sorted { $0.date < $1.date },
            text: $viewModel.uiState.text,
            onSendMessagesClick: viewModel.sendMessage,
            onBackClick: onBackClick,
            loadMoreMessages: viewModel.loadMoreMessages,
            onErrorMessageClick: viewModel.deleteErrorMessage,
            onResendMessage: viewModel.resendErrorMessage,
            onInterlocutorClick: onInterlocutorClick
        )
        .onReceive(viewModel.$event) { event in
            if let errorEvent = event as? ErrorEvent {
                errorMessage = errorEvent.message
                showErrorAlert = true
            }
        }
        .alert(
            errorMessage,
            isPresented: $showErrorAlert
        ) {
            Button(
                getString(.ok),
                action: { showErrorAlert = false }
            )
        }
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
    let onErrorMessageClick: (Message) -> Void
    let onResendMessage: (Message) -> Void
    let onInterlocutorClick: (User) -> Void
    
    @State private var showBottomSheet: Bool = false
    @State private var inputFocused: Bool = false
    @State private var selectedMessage: Message?
    @State private var showDeleteAnnouncementAlert: Bool = false

    var body: some View {
        VStack(spacing: GedSpacing.medium) {
            MessageFeed(
                messages: messages,
                conversation: conversation,
                loadMoreMessages: loadMoreMessages,
                onErrorMessageClick: {
                    if $0.state == .error {
                        selectedMessage = $0
                        showBottomSheet = true
                    }
                }
            )
            
            MessageInput(
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
        .sheet(isPresented: $showBottomSheet) {
            BottomSheetContainer(fraction: 0.16) {
                ClickableTextItem(
                    icon: Image(systemName: "paperplane"),
                    text: Text(getString(.resend))
                ) {
                    showBottomSheet = false
                    if let message = selectedMessage {
                        onResendMessage(message)
                    }
                }
                                
                ClickableTextItem(
                    icon: Image(systemName: "trash"),
                    text: Text(getString(.delete))
                ) {
                    showBottomSheet = false
                    showDeleteAnnouncementAlert = true
                }
                .foregroundColor(.error)
            }
        }
        .alert(
            getString(.deleteMessageAlertTitle),
            isPresented: $showDeleteAnnouncementAlert,
            actions: {
                Button(getString(.cancel), role: .cancel) {
                    showDeleteAnnouncementAlert = false
                }
                
                Button(getString(.delete), role: .destructive) {
                    if let message = selectedMessage {
                        onErrorMessageClick(message)
                    }
                    showDeleteAnnouncementAlert = false
                }
            },
            message: { Text(getString(.deleteMessageAlertContent)) }
        )
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
                    
                    HStack {
                        ProfilePicture(
                            url: conversation.interlocutor.profilePictureUrl,
                            scale: 0.4
                        )
                        
                        Text(conversation.interlocutor.fullName)
                            .fontWeight(.medium)
                    }
                    .onTapGesture {
                        onInterlocutorClick(conversation.interlocutor)
                    }
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
            loadMoreMessages: {},
            onErrorMessageClick: { _ in },
            onResendMessage: { _ in },
            onInterlocutorClick: { _ in }
        )
        .background(Color.background)
    }
}
