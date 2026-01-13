import SwiftUI

struct ConversationDestination: View {
    let onConversationClick: (Conversation) -> Void
    
    @StateObject private var viewModel = MessageMainThreadInjector.shared.resolve(ConversationViewModel.self)
    @State private var showErrorAlert: Bool = false
    @State private var errorMessage: String = ""
    
    var body: some View {
        ConversationView(
            conversationsUi: viewModel.uiState.conversations,
            onConversationClick: onConversationClick,
            onDeleteConversationClick: viewModel.deleteConversation,
            onCreateConversationClick: { interlocutor in
                Task { @MainActor in
                    if let conversation = await viewModel.getConversation(interlocutor: interlocutor) {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            onConversationClick(conversation)
                        }
                    }
                }
            },
            onRecreateConversationClick: viewModel.recreateConversation
        )
        .onReceive(viewModel.$event) { event in
            if let errorEvent = event as? ErrorEvent {
                errorMessage = errorEvent.message
                showErrorAlert = true
            }
        }
        .alert(
            errorMessage,
            isPresented: $showErrorAlert,
            actions: {
                Button(stringResource(.ok)) {
                    showErrorAlert = false
                }
            }
        )
    }
}

private struct ConversationView: View {
    let conversationsUi: [ConversationUi]?
    let onConversationClick: (Conversation) -> Void
    let onDeleteConversationClick: (Conversation) -> Void
    let onCreateConversationClick: (User) -> Void
    let onRecreateConversationClick: (Conversation) -> Void
    
    @State private var showDeleteAlert: Bool = false
    @State private var alertConversation: Conversation?
    @State private var activeSheet: ConversationViewSheet?

    var body: some View {
        Group {
            if let conversationsUi {
                ConversationList(
                    conversationsUi: conversationsUi,
                    onConversationClick: {
                        if $0.state == .created {
                            onConversationClick($0.toConversation())
                        } else {
                            activeSheet = .conversation($0.toConversation())
                        }
                    },
                    onLongConversationClick: {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        activeSheet = .conversation($0.toConversation())
                    },
                    onNewConversationClick: {
                        activeSheet = .createConversation
                    }
                )
            } else {
                ProgressView()
                    .padding(.top)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .background(.appBackground)
            }
        }
        .navigationTitle(stringResource(.messages))
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(
                    action: { activeSheet = .createConversation },
                    label: { Image(systemName: "plus") }
                )
            }
        }
        .alert(
            stringResource(.deleteConversationAlertTitle),
            isPresented: $showDeleteAlert,
            presenting: alertConversation,
            actions: { conversation in
                Button(stringResource(.cancel), role: .cancel) {
                    showDeleteAlert = false
                    alertConversation = nil
                }
                
                Button(stringResource(.delete), role: .destructive) {
                    showDeleteAlert = false
                    alertConversation = nil
                    onDeleteConversationClick(conversation)
                }
            },
            message: { _ in
                Text(stringResource(.deleteConversationAlertMessage))
            }
        )
        .sheet(item: $activeSheet) {
            switch $0 {
                case let .conversation(conversation):
                    ConversationSheet(
                        conversationState: conversation.state,
                        onRecreateClick: {
                            activeSheet = nil
                            onRecreateConversationClick(conversation)
                        },
                        onDeleteClick: {
                            activeSheet = nil
                            alertConversation = conversation
                            showDeleteAlert = true
                        }
                    )
                    
                case .createConversation:
                    NavigationStack {
                        CreateConversationDestination(
                            onUserClick: { user in
                                activeSheet = nil
                                onCreateConversationClick(user)
                            },
                            onCancelClick: { activeSheet = nil }
                        )
                        .presentationDetents([.large])
                    }
            }
        }
    }
}

private struct ConversationList: View {
    let conversationsUi: [ConversationUi]
    let onConversationClick: (ConversationUi) -> Void
    let onLongConversationClick: (ConversationUi) -> Void
    let onNewConversationClick: () -> Void
    
    var body: some View {
        PlainTableView(
            modifier: PlainTableModifier(
                backgroundColor: .appBackground,
                onRowLongClick: onLongConversationClick
            ),
            values: conversationsUi,
            onRowClick: onConversationClick,
            emptyContent: {
                EmptyConversationView(
                    onNewConversationClick: onNewConversationClick
                )
            },
            content: {
                ConversationItem(conversationUi: $0)
            }
        )
    }
}

private struct EmptyConversationView: View {
    let onNewConversationClick: () -> Void
    
    var body: some View {
        VStack {
            Text(stringResource(.noConversation))
                .foregroundStyle(.informationText)
            
            Button(
                stringResource(.newConversation),
                action: onNewConversationClick
            )
            .fontWeight(.semibold)
            .foregroundStyle(.gedPrimary)
        }
    }
}

private enum ConversationViewSheet: Identifiable {
    case conversation(Conversation)
    case createConversation
    
    var id: Int {
        switch self {
            case .conversation: 0
            case .createConversation: 1
        }
    }
}

#Preview {
    NavigationStack {
        ConversationView(
            conversationsUi: conversationsUiFixture,
            onConversationClick: {_ in},
            onDeleteConversationClick: {_ in},
            onCreateConversationClick: { _ in},
            onRecreateConversationClick: {_ in}
        )
    }
    .environment(\.managedObjectContext, GedDatabaseContainer.preview.container.viewContext)
}
