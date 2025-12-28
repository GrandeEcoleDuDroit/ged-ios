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
            messageText: $viewModel.uiState.messageText,
            loading: viewModel.uiState.loading,
            blockedUser: viewModel.uiState.blockedUser,
            canLoadMoreMessages: viewModel.uiState.canLoadMoreMessages,
            newMessagesEventPublisher: viewModel.newMessagesEventPublisher,
            onSendMessagesClick: viewModel.sendMessage,
            onMessageTextChange: viewModel.onMessageTextChange,
            loadMoreMessages: viewModel.loadMoreMessages,
            onDeleteErrorMessageClick: viewModel.deleteErrorMessage,
            onResendMessage: viewModel.resendErrorMessage,
            onInterlocutorClick: onInterlocutorClick,
            onReportMessageClick: viewModel.reportMessage,
            onDeleteChatClick: viewModel.deleteChat,
            onUnblockUserClick: viewModel.unblockUser,
            onInterlocutorProfilePictureClick: onInterlocutorClick,
            onBackClick: onBackClick
        )
        .onReceive(viewModel.$event) { event in
            if let errorEvent = event as? ErrorEvent {
                errorMessage = errorEvent.message
                showErrorAlert = true
            } else if let chatEvent = event as? ChatViewModel.ChatEvent {
                if case .chatDeleted = chatEvent {
                    onBackClick()
                }
            }
        }
        .alert(
            errorMessage,
            isPresented: $showErrorAlert,
            actions: {
                Button(
                    stringResource(.ok),
                    action: { showErrorAlert = false }
                )
            }
        )
    }
}

private struct ChatView: View {
    let conversation: Conversation
    let messages: [Message]
    @Binding var messageText: String
    let loading: Bool
    let blockedUser: Bool
    let canLoadMoreMessages: Bool
    let newMessagesEventPublisher: AnyPublisher<Bool, Never>
    
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
    let onBackClick: () -> Void
    
    @State private var activeSheet: ChatViewSheet?
    @State private var alertMessage: Message?
    @State private var showDeleteMessageAlert: Bool = false
    @State private var showDeleteChatAlert: Bool = false
    @State private var showUnblockUserAlert: Bool = false
    
    var body: some View {
        MessageFeed(
            messages: messages,
            conversation: conversation,
            canLoadMoreMessages: canLoadMoreMessages,
            loadMoreMessages: loadMoreMessages,
            newMessagesEventPublisher: newMessagesEventPublisher,
            onErrorMessageClick: {
                if $0.state == .error {
                    activeSheet = .sentMessage($0)
                }
            },
            onReceivedMessageLongClick: {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                activeSheet = .receivedMessage($0)
            },
            onInterlocutorProfilePictureClick: { onInterlocutorProfilePictureClick(conversation.interlocutor) }
        )
        .safeAreaInset(edge: .bottom) {
            MessageBottomSection(
                blockedUser: blockedUser,
                messageText: $messageText,
                onMessageTextChange: onMessageTextChange,
                onSendMessagesClick: onSendMessagesClick,
                onDeleteChatClick: { showDeleteChatAlert = true },
                onUnblockUserClick: { showUnblockUserAlert = true }
            )
            .padding(.top, 2)
            .padding(.horizontal)
        }
        .loading(loading)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                HStack(spacing: Dimens.smallMediumPadding) {
                    ProfilePicture(
                        url: conversation.interlocutor.profilePictureUrl,
                        scale: 0.3
                    )
                    
                    Text(conversation.interlocutor.displayedName)
                        .fontWeight(.medium)
                }
                .onTapGesture {
                    onInterlocutorClick(conversation.interlocutor)
                }
            }
        }
        .sheet(item: $activeSheet) {
            switch $0 {
                case let .sentMessage(message):
                    SentMessageSheet(
                        onResendMessage: {
                            activeSheet = nil
                            onResendMessage(message)
                        },
                        onDeleteMessage: {
                            activeSheet = nil
                            alertMessage = message
                            showDeleteMessageAlert = true
                        }
                    )
                    
                case let .receivedMessage(message):
                    ReceivedMessageSheet(
                        onReportClick: {
                            activeSheet = .messageReport(message)
                        }
                    )
                    
                case let .messageReport(message):
                    ReportSheet(
                        items: MessageReport.Reason.allCases,
                        fraction: Dimens.reportSheetFraction(itemCount: MessageReport.Reason.allCases.count),
                        onReportClick: { reason in
                            activeSheet = nil
                            onReportMessageClick(
                                MessageReport(
                                    conversationId: conversation.id,
                                    messageId: message.id,
                                    recipient: MessageReport.Recipient(
                                        fullName: conversation.interlocutor.fullName,
                                        email: conversation.interlocutor.email
                                    ),
                                    reason: reason
                                )
                            )
                        }
                    )
            }
        }
        .alert(
            stringResource(.deleteMessageAlertContent),
            isPresented: $showDeleteMessageAlert,
            presenting: alertMessage,
            actions: { message in
                Button(stringResource(.cancel), role: .cancel) {
                    showDeleteMessageAlert = false
                    alertMessage = nil
                }
                
                Button(stringResource(.delete), role: .destructive) {
                    showDeleteMessageAlert = false
                    alertMessage = nil
                    onDeleteErrorMessageClick(message)
                }
            }
        )
        .alert(
            stringResource(.deleteConversationAlertTitle),
            isPresented: $showDeleteChatAlert,
            actions: {
                Button(
                    stringResource(.cancel),
                    role: .cancel,
                    action: { showDeleteChatAlert = false }
                )
                
                Button(
                    stringResource(.unblock),
                    role: .destructive,
                    action: {
                        showDeleteChatAlert = false
                        onDeleteChatClick()
                    }
                )
            },
            message: { Text(stringResource(.deleteConversationAlertMessage)) }
        )
        .alert(
            stringResource(.unblockUserAlertMessage),
            isPresented: $showUnblockUserAlert,
            actions: {
                Button(
                    stringResource(.cancel),
                    role: .cancel,
                    action: { showUnblockUserAlert = false }
                )
                
                Button(stringResource(.unblock)) {
                    showUnblockUserAlert = false
                    onUnblockUserClick(conversation.interlocutor.id)
                }
            }
        )
    }
}

private struct SentMessageSheet: View {
    let onResendMessage: () -> Void
    let onDeleteMessage: () -> Void
    
    var body: some View {
        SheetContainer(fraction: Dimens.sheetFraction(itemCount: 2)) {
            ClickableTextItem(
                icon: Image(systemName: "paperplane"),
                text: Text(stringResource(.resend)),
                onClick: onResendMessage
            )
                            
            ClickableTextItem(
                icon: Image(systemName: "trash"),
                text: Text(stringResource(.delete)),
                onClick: onDeleteMessage
            )
            .foregroundColor(.red)
        }
    }
}

private struct ReceivedMessageSheet: View {
    let onReportClick: () -> Void
    
    var body: some View {
        SheetContainer(fraction: Dimens.sheetFraction(itemCount: 1)) {
            ClickableTextItem(
                icon: Image(systemName: "exclamationmark.bubble"),
                text: Text(stringResource(.report)),
                onClick: onReportClick
            )
            .foregroundColor(.red)
        }
    }
}

private struct MessageBottomSection: View {
    let blockedUser: Bool
    @Binding var messageText: String
    let onMessageTextChange: (String) -> Void
    let onSendMessagesClick: () -> Void
    let onDeleteChatClick: () -> Void
    let onUnblockUserClick: () -> Void
    
    var body: some View {
        if blockedUser {
            MessageBlockedUserIndicator(
                onDeleteChatClick: onDeleteChatClick,
                onUnblockUserClick: onUnblockUserClick
            )
        } else {
            MessageInput(
                text: $messageText,
                onTextChange: onMessageTextChange,
                onSendClick: onSendMessagesClick
            )
        }
    }
}

private enum ChatViewSheet: Identifiable {
    case sentMessage(Message)
    case receivedMessage(Message)
    case messageReport(Message)
    
    var id: Int {
        switch self {
            case .sentMessage: 0
            case .receivedMessage: 1
            case .messageReport: 2
        }
    }
}

#Preview {
    NavigationStack {
        ChatView(
            conversation: conversationFixture,
            messages: messagesFixture,
            messageText: .constant(""),
            loading: false,
            blockedUser: false,
            canLoadMoreMessages: true,
            newMessagesEventPublisher: Empty().eraseToAnyPublisher(),
            onSendMessagesClick: {},
            onMessageTextChange: { _ in },
            loadMoreMessages: { _ in },
            onDeleteErrorMessageClick: { _ in },
            onResendMessage: { _ in },
            onInterlocutorClick: { _ in },
            onReportMessageClick: { _ in },
            onDeleteChatClick: {},
            onUnblockUserClick: { _ in },
            onInterlocutorProfilePictureClick: { _ in },
            onBackClick: {}
        )
    }
}
