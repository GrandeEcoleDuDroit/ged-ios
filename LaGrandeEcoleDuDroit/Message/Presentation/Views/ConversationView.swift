import SwiftUI

struct ConversationView: View {
    @EnvironmentObject private var conversationViewModel: ConversationViewModel
    @State private var conversationToOpen: ConversationUI? = nil
    @State private var selectedConversation: ConversationUI? = nil
    @State private var showCreateConversationView: Bool = false
    @State private var showBottomSheet: Bool = false
    @State private var isBottomSheetItemClicked: Bool = false
    @State private var showDeleteAlert: Bool = false
    
    var body: some View {
        ZStack {
            if conversationViewModel.conversationsMap.isEmpty {
                Text(getString(.noConversation))
                    .font(.bodyLarge)
                    .foregroundColor(.secondary)
                    .padding(.vertical)
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(conversationViewModel.conversationsMap.sortedByDate(), id: \.id) { conversation in
                            GetConversationItem(
                                conversation: conversation,
                                onClick: { conversationToOpen = conversation },
                                onLongClick: {
                                    selectedConversation = conversation
                                    showBottomSheet = true
                                }
                            )
                            .background(
                                NavigationLink(
                                    destination: ChatView(conversation: conversation)
                                        .environmentObject(
                                            ChatViewModel(
                                                getMessagesUseCase: DependencyContainer.shared.getMessagesUseCase,
                                                getCurrentUserUseCase: DependencyContainer.shared.getCurrentUserUseCase,
                                                generateIdUseCase: DependencyContainer.shared.generateIdUseCase,
                                                createConversationUseCase: DependencyContainer.shared.createConversationUseCase,
                                                conversation: conversation
                                            )
                                        ),
                                    tag: conversation,
                                    selection: $conversationToOpen,
                                    label: { EmptyView() }
                                )
                                .hidden()
                            )
                        }
                    }
                }
                .sheet(isPresented: $showBottomSheet) {
                    Text(getString(.delete))
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .contentShape(Rectangle())
                        .onClick(isClicked: $isBottomSheetItemClicked) {
                            showBottomSheet = false
                            showDeleteAlert = true
                        }
                }
            }
        }
        .searchable(
            text: $conversationViewModel.searchConversations,
            placement: .navigationBarDrawer(displayMode: .always)
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .navigationTitle(getString(.messages))
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(
                    destination:
                        CreateConversationView()
                        .environmentObject(DependencyContainer.shared.createConversationViewModel)
                ) {
                    Image(systemName: "plus")
                }
            }
        }
        .alert(
            getString(.deleteConversationAlertMessage),
            isPresented: $showDeleteAlert
        ) {
            Button(getString(.cancel), role: .cancel) {
                showDeleteAlert = false
            }
            Button(getString(.delete), role: .destructive) {
                if let conversation = selectedConversation {
                    conversationViewModel.deleteConversation(conversationId: conversation.id)
                }
                showDeleteAlert = false
            }
        }
    }
}

struct GetConversationItem: View {
    private var conversation: ConversationUI
    private let onClick: () -> Void
    private let onLongClick: () -> Void
    
    init(
        conversation: ConversationUI,
        onClick: @escaping () -> Void,
        onLongClick: @escaping () -> Void
    ) {
        self.conversation = conversation
        self.onClick = onClick
        self.onLongClick = onLongClick
    }
    
    var body: some View {
        if let lastMessage = conversation.lastMessage {
            if lastMessage.isRead {
                ReadConversationItem(
                    conversationUI: conversation,
                    onClick: onClick,
                    onLongClick: onLongClick
                )
            } else {
                UnreadConversationItem(
                    conversationUI: conversation,
                    onClick: onClick,
                    onLongClick: onLongClick
                )
            }
        }
        else {
            EmptyConversationItem(
                conversationUI: conversation,
                onClick: onClick,
                onLongClick: onLongClick
            )
        }
    }
}

#Preview {
    NavigationView {
        ConversationView()
            .environmentObject(DependencyContainer.shared.mockConversationViewModel)
    }
}
