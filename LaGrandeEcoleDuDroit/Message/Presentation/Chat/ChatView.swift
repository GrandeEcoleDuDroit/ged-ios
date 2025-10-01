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
            onSendMessagesClick: viewModel.sendMessage,
            onBackClick: onBackClick,
            loadMoreMessages: viewModel.loadMoreMessages,
            onErrorMessageClick: viewModel.deleteErrorMessage,
            onResendMessage: viewModel.resendErrorMessage,
            onInterlocutorClick: onInterlocutorClick,
            onReportMessageClick: viewModel.reportMessage
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
    @Binding var messageText: String
    let loading: Bool
    let onSendMessagesClick: () -> Void
    let onBackClick: () -> Void
    let loadMoreMessages: () -> Void
    let onErrorMessageClick: (Message) -> Void
    let onResendMessage: (Message) -> Void
    let onInterlocutorClick: (User) -> Void
    let onReportMessageClick: (MessageReport) -> Void
    
    @State private var showSentMessageBottomSheet: Bool = false
    @State private var showReceivedMessageBottomSheet: Bool = false
    @State private var showReportMessageBottomSheet: Bool = false
    @State private var inputFocused: Bool = false
    @State private var clickedMessage: Message?
    @State private var showDeleteAnnouncementAlert: Bool = false

    var body: some View {
        VStack(spacing: GedSpacing.medium) {
            MessageFeed(
                messages: messages,
                conversation: conversation,
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
                }
            )
            
            MessageInput(
                text: $messageText,
                inputFocused: $inputFocused,
                onSendClick: onSendMessagesClick
            )
        }
        .padding(.horizontal)
        .contentShape(Rectangle())
        .onTapGesture {
            inputFocused = false
        }
        .loading(loading)
        .sheet(isPresented: $showSentMessageBottomSheet) {
            SentMessageBottomSheet(
                onResendMessage: {
                    showSentMessageBottomSheet = false
                    if let message = clickedMessage {
                        onResendMessage(message)
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
                    
                    if let message = clickedMessage {
                        onReportMessageClick(
                            MessageReport(
                                conversationId: conversation.id,
                                messageId: message.id,
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
            getString(.deleteMessageAlertTitle),
            isPresented: $showDeleteAnnouncementAlert,
            actions: {
                Button(getString(.cancel), role: .cancel) {
                    showDeleteAnnouncementAlert = false
                }
                
                Button(getString(.delete), role: .destructive) {
                    if let message = clickedMessage {
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
                    
                    HStack(spacing: GedSpacing.smallMedium) {
                        ProfilePicture(
                            url: conversation.interlocutor.profilePictureUrl,
                            scale: 0.3
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

#Preview {
    NavigationStack {
        ChatView(
            conversation: conversationFixture,
            messages: messagesFixture,
            messageText: .constant(""),
            loading: false,
            onSendMessagesClick: {},
            onBackClick: {},
            loadMoreMessages: {},
            onErrorMessageClick: { _ in },
            onResendMessage: { _ in },
            onInterlocutorClick: { _ in },
            onReportMessageClick: { _ in }
        )
        .background(Color.background)
    }
}
