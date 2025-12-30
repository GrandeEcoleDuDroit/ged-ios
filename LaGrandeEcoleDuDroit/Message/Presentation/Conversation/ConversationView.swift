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
        List {
            if let conversationsUi {
                if conversationsUi.isEmpty {
                    EmptyConversationView(
                        onNewConversationClick: {
                            activeSheet = .createConversation
                        }
                    )
                } else {
                    ConversationListContent(
                        conversationsUi: conversationsUi,
                        onConversationClick: {
                            if $0.state == .created {
                                onConversationClick($0)
                            } else {
                                activeSheet = .conversation($0)
                            }
                        },
                        onLongConversationClick: {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            activeSheet = .conversation($0)
                        }
                    )
                }
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
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

private struct ConversationListContent: View {
    let conversationsUi: [ConversationUi]
    let onConversationClick: (Conversation) -> Void
    let onLongConversationClick: (Conversation) -> Void
    
    @State private var selectedConversationUi: ConversationUi?

    var body: some View {
        ForEach(conversationsUi) { conversationUi in
            ConversationItem(conversationUi: conversationUi)
                .contentShape(.rect)
                .simultaneousGesture(
                    LongPressGesture()
                        .onEnded { _ in
                            onLongConversationClick(conversationUi.toConversation())
                        }
                )
                .listRowTap(
                    value: conversationUi,
                    selectedItem: $selectedConversationUi
                ) {
                    onConversationClick(conversationUi.toConversation())
                }
                .listRowBackground(selectedConversationUi == conversationUi ? Color.click : Color.clear)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets())
        }
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
        .frame(maxWidth: .infinity, alignment: .center)
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
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
        .background(.appBackground)
    }
    .environment(\.managedObjectContext, GedDatabaseContainer.preview.container.viewContext)
}
