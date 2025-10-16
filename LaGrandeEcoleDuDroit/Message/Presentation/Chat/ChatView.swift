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
            wrappedValue: MessageMainThreadInjector.shared.resolve(ChatViewModel.self, arguments: conversation)!
        )
        self.onBackClick = onBackClick
        self.onInterlocutorClick = onInterlocutorClick
    }
    
    var body: some View {
        ChatView(
            conversation: conversation,
            messages: viewModel.uiState.messages,
            messageText: viewModel.uiState.messageText,
            loading: viewModel.uiState.loading,
            userBlocked: viewModel.uiState.userBlocked,
            canLoadMoreMessages: viewModel.uiState.canLoadMoreMessages,
            onSendMessagesClick: viewModel.sendMessage,
            onMessageTextChange: viewModel.onMessageTextChange,
            loadMoreMessages: viewModel.loadMoreMessages,
            onDeleteErrorMessageClick: viewModel.deleteErrorMessage,
            onResendMessage: viewModel.resendErrorMessage,
            onInterlocutorClick: onInterlocutorClick,
            onReportMessageClick: viewModel.reportMessage,
            onDeleteChatClick: viewModel.deleteChat,
            onUnblockUserClick: viewModel.unblockUser,
            onInterlocutorProfilePictureClick: onInterlocutorClick
        )
        .onReceive(viewModel.$event) { event in
            if let errorEvent = event as? ErrorEvent {
                errorMessage = errorEvent.message
                showErrorAlert = true
            } else if let messageEvent = event as? ChatViewModel.MessageEvent {
                switch messageEvent {
                    case .chatDeleted: onBackClick()
                }
            }
        }
        .alert(
            errorMessage,
            isPresented: $showErrorAlert,
            actions: {
                Button(
                    getString(.ok),
                    action: { showErrorAlert = false }
                )
            }
        )
    }
}

private struct ChatView: View {
    let conversation: Conversation
    let messages: [Message]
    let messageText: String
    let loading: Bool
    let userBlocked: Bool
    let canLoadMoreMessages: Bool
    let onSendMessagesClick: () -> Void
    let onMessageTextChange: (String) -> Void
    let loadMoreMessages: (Int) -> Void
    let onDeleteErrorMessageClick: (Message) -> Void
    let onResendMessage: (Message) -> Void
    let onInterlocutorClick: (User) -> Void
    let onReportMessageClick: (MessageReport) -> Void
    let onDeleteChatClick: () -> Void
    let onUnblockUserClick: (String) -> Void
    let onInterlocutorProfilePictureClick: (User) -> Void
    
    @State private var showSentMessageBottomSheet: Bool = false
    @State private var showReceivedMessageBottomSheet: Bool = false
    @State private var showReportMessageBottomSheet: Bool = false
    @State private var clickedMessage: Message?
    @State private var showDeleteAnnouncementAlert: Bool = false
    @State private var showDeleteChatAlert: Bool = false
    @State private var showUnblockAlert: Bool = false
    private let interlocutorName: String
    
    init(
        conversation: Conversation,
        messages: [Message],
        messageText: String,
        loading: Bool,
        userBlocked: Bool,
        canLoadMoreMessages: Bool,
        onSendMessagesClick: @escaping () -> Void,
        onMessageTextChange: @escaping (String) -> Void,
        loadMoreMessages: @escaping (Int) -> Void,
        onDeleteErrorMessageClick: @escaping (Message) -> Void,
        onResendMessage: @escaping (Message) -> Void,
        onInterlocutorClick: @escaping (User) -> Void,
        onReportMessageClick: @escaping (MessageReport) -> Void,
        onDeleteChatClick: @escaping () -> Void,
        onUnblockUserClick: @escaping (String) -> Void,
        onInterlocutorProfilePictureClick: @escaping (User) -> Void
    ) {
        self.conversation = conversation
        self.messages = messages
        self.messageText = messageText
        self.loading = loading
        self.userBlocked = userBlocked
        self.canLoadMoreMessages = canLoadMoreMessages
        self.onSendMessagesClick = onSendMessagesClick
        self.onMessageTextChange = onMessageTextChange
        self.loadMoreMessages = loadMoreMessages
        self.onDeleteErrorMessageClick = onDeleteErrorMessageClick
        self.onResendMessage = onResendMessage
        self.onInterlocutorClick = onInterlocutorClick
        self.onReportMessageClick = onReportMessageClick
        self.onDeleteChatClick = onDeleteChatClick
        self.onUnblockUserClick = onUnblockUserClick
        self.onInterlocutorProfilePictureClick = onInterlocutorProfilePictureClick
        self.interlocutorName = conversation.interlocutor.isDeleted ? getString(.deletedUser) : conversation.interlocutor.fullName
    }

    var body: some View {
        VStack(spacing: GedSpacing.smallMedium) {
            MessageFeed(
                messages: messages,
                conversation: conversation,
                canLoadMoreMessages: canLoadMoreMessages,
                loadMoreMessages: loadMoreMessages,
                onErrorMessageClick: {
                    if $0.state == .error {
                        clickedMessage = $0
                        showSentMessageBottomSheet = true
                    }
                },
                onReceivedMessageLongClick: {
                    clickedMessage = $0
                    showReceivedMessageBottomSheet = true
                },
                onInterlocutorProfilePictureClick: { onInterlocutorProfilePictureClick(conversation.interlocutor) }
            )
            
            MessageBottomSection(
                userBlocked: userBlocked,
                messageText: messageText,
                onMessageTextChange: onMessageTextChange,
                onSendMessagesClick: onSendMessagesClick,
                onDeleteChatClick: { showDeleteChatAlert = true },
                onUnblockUserClick: { showUnblockAlert = true }
            )
        }
        .padding(.horizontal)
        .contentShape(Rectangle())
        .loading(loading)
        .sheet(isPresented: $showSentMessageBottomSheet) {
            SentMessageBottomSheet(
                onResendMessage: {
                    showSentMessageBottomSheet = false
                    if let clickedMessage {
                        onResendMessage(clickedMessage)
                    }
                },
                onDeleteMessage: {
                    showSentMessageBottomSheet = false
                    showDeleteAnnouncementAlert = true
                }
            )
        }
        .sheet(isPresented: $showReceivedMessageBottomSheet) {
            ReceivedMessageBottomSheet(
                onReportClick: {
                    showReceivedMessageBottomSheet = false
                    showReportMessageBottomSheet = true
                }
            )
        }
        .sheet(isPresented: $showReportMessageBottomSheet) {
            ReportBottomSheet(
                items: MessageReport.Reason.allCases,
                fraction: 0.5,
                onReportClick: { reason in
                    showReportMessageBottomSheet = false
                    
                    if let clickedMessage {
                        onReportMessageClick(
                            MessageReport(
                                conversationId: conversation.id,
                                messageId: clickedMessage.id,
                                recipientInfo: MessageReport.UserInfo(
                                    fullName: conversation.interlocutor.fullName,
                                    email: conversation.interlocutor.email
                                ),
                                reason: reason
                            )
                        )
                    }
                }
            )
        }
        .alert(
            getString(.deleteMessageAlertContent),
            isPresented: $showDeleteAnnouncementAlert,
            actions: {
                Button(getString(.cancel), role: .cancel) {
                    showDeleteAnnouncementAlert = false
                }
                
                Button(getString(.delete), role: .destructive) {
                    if let clickedMessage {
                        onDeleteErrorMessageClick(clickedMessage)
                    }
                    showDeleteAnnouncementAlert = false
                }
            }
        )
        .alert(
            getString(.deleteConversationAlertTitle),
            isPresented: $showDeleteChatAlert,
            actions: {
                Button(
                    getString(.cancel),
                    role: .cancel,
                    action: { showUnblockAlert = false }
                )
                
                Button(
                    getString(.unblock),
                    role: .destructive,
                    action: {
                        showDeleteChatAlert = false
                        onDeleteChatClick()
                    }
                )
            },
            message: { Text(getString(.deleteConversationAlertMessage)) }
        )
        .alert(
            getString(.unblockUserAlertMessage),
            isPresented: $showUnblockAlert,
            actions: {
                Button(
                    getString(.cancel),
                    role: .cancel,
                    action: { showUnblockAlert = false }
                )
                
                Button(
                    getString(.unblock),
                    action: {
                        showUnblockAlert = false
                        onUnblockUserClick(conversation.interlocutor.id)
                    }
                )
            }
        )
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                HStack(spacing: GedSpacing.smallMedium) {
                    ProfilePicture(
                        url: conversation.interlocutor.profilePictureUrl,
                        scale: 0.3
                    )
                    
                    Text(interlocutorName)
                        .fontWeight(.medium)
                }
                .onTapGesture {
                    onInterlocutorClick(conversation.interlocutor)
                }
            }
        }
    }
}

private struct SentMessageBottomSheet: View {
    let onResendMessage: () -> Void
    let onDeleteMessage: () -> Void
    
    var body: some View {
        BottomSheetContainer(fraction: 0.16) {
            ClickableTextItem(
                icon: Image(systemName: "paperplane"),
                text: Text(getString(.resend)),
                onClick: onResendMessage
            )
                            
            ClickableTextItem(
                icon: Image(systemName: "trash"),
                text: Text(getString(.delete)),
                onClick: onDeleteMessage
            )
            .foregroundColor(.red)
        }
    }
}

private struct ReceivedMessageBottomSheet: View {
    let onReportClick: () -> Void
    
    var body: some View {
        BottomSheetContainer(fraction: 0.1) {
            ClickableTextItem(
                icon: Image(systemName: "exclamationmark.bubble"),
                text: Text(getString(.report)),
                onClick: onReportClick
            )
            .foregroundColor(.red)
        }
    }
}

private struct MessageBottomSection: View {
    let userBlocked: Bool
    let messageText: String
    let onMessageTextChange: (String) -> Void
    let onSendMessagesClick: () -> Void
    let onDeleteChatClick: () -> Void
    let onUnblockUserClick: () -> Void
    
    var body: some View {
        if userBlocked {
            MessageBlockedUserIndicator(
                onDeleteChatClick: onDeleteChatClick,
                onUnblockUserClick: onUnblockUserClick
            )
        } else {
            MessageInput(
                text: messageText,
                onTextChange: onMessageTextChange,
                onSendClick: onSendMessagesClick
            )
        }
    }
}

#Preview {
    NavigationStack {
        ChatView(
            conversation: conversationFixture,
            messages: messagesFixture,
            messageText: "",
            loading: false,
            userBlocked: false,
            canLoadMoreMessages: true,
            onSendMessagesClick: {},
            onMessageTextChange: { _ in },
            loadMoreMessages: { _ in },
            onDeleteErrorMessageClick: { _ in },
            onResendMessage: { _ in },
            onInterlocutorClick: { _ in },
            onReportMessageClick: { _ in },
            onDeleteChatClick: {},
            onUnblockUserClick: { _ in },
            onInterlocutorProfilePictureClick: { _ in }
        )
        .background(Color.background)
    }
}
