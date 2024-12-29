import SwiftUI

struct ConversationView: View {
    @EnvironmentObject private var conversationViewModel: ConversationViewModel
    @EnvironmentObject private var tabBarVisibility: TabBarVisibility
    @EnvironmentObject private var coordinator: MessageNavigationCoordinator
    @State private var selectedConversation: ConversationUI? = nil
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
                            NavigationLink(value: MessageScreen.chat(conversation: conversation)) {
                                GetConversationItem(
                                    conversation: conversation,
                                    onLongClick: {
                                        selectedConversation = conversation
                                        showBottomSheet = true
                                    }
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                .sheet(isPresented: $showBottomSheet) {
                    ItemWithIcon(
                        icon: Image(systemName: "trash"),
                        text: Text(getString(.delete))
                    )
                    .font(.title3)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .contentShape(Rectangle())
                    .onClick(isClicked: $isBottomSheetItemClicked) {
                        showBottomSheet = false
                        showDeleteAlert = true
                    }
                    .presentationDetents([.fraction(0.10)])
                }
            }
        }
        .navigationDestination(for: MessageScreen.self) { screen in
            switch screen {
            case .chat(let conversation):
                ChatView(conversation: conversation)
                    .environmentObject(
                        ChatViewModel(
                            getMessagesUseCase: DependencyContainer.shared.getMessagesUseCase,
                            getCurrentUserUseCase: DependencyContainer.shared.getCurrentUserUseCase,
                            generateIdUseCase: DependencyContainer.shared.generateIdUseCase,
                            createConversationUseCase: DependencyContainer.shared.createConversationUseCase,
                            conversation: conversation
                        )
                    )
                    .environmentObject(tabBarVisibility)
                    .environmentObject(coordinator)
            case .createConversation:
                CreateConversationView()
                    .environmentObject(DependencyContainer.shared.createConversationViewModel)
                    .environmentObject(tabBarVisibility)
                    .environmentObject(coordinator)
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
                NavigationLink(value: MessageScreen.createConversation) {
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
        .onAppear {
            tabBarVisibility.show = true
        }
    }
}

struct GetConversationItem: View {
    private var conversation: ConversationUI
    private let onLongClick: () -> Void
    
    init(
        conversation: ConversationUI,
        onLongClick: @escaping () -> Void
    ) {
        self.conversation = conversation
        self.onLongClick = onLongClick
    }
    
    var body: some View {
        if let lastMessage = conversation.lastMessage {
            if lastMessage.isRead {
                ReadConversationItem(
                    conversationUI: conversation,
                    onLongClick: onLongClick
                )
            } else {
                UnreadConversationItem(
                    conversationUI: conversation,
                    onLongClick: onLongClick
                )
            }
        }
        else {
            EmptyConversationItem(
                conversationUI: conversation,
                onLongClick: onLongClick
            )
        }
    }
}

#Preview {
    NavigationStack {
        ConversationView()
            .environmentObject(DependencyContainer.shared.mockConversationViewModel)
            .environmentObject(TabBarVisibility())
            .environmentObject(MessageNavigationCoordinator())
    }
}
