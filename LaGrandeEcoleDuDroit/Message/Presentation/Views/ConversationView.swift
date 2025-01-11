import SwiftUI

struct ConversationView: View {
    @EnvironmentObject private var conversationViewModel: ConversationViewModel
    @EnvironmentObject private var tabBarVisibility: TabBarVisibility
    @EnvironmentObject private var navigationCoordinator: NavigationCoordinator
    @State private var selectedConversation: ConversationUI? = nil
    @State private var showBottomSheet: Bool = false
    @State private var isBottomSheetItemClicked: Bool = false
    @State private var showDeleteAlert: Bool = false
    
    var body: some View {
        ZStack {
            if conversationViewModel.conversationsMap.isEmpty {
                VStack {
                    Text(getString(.noConversation))
                        .foregroundColor(.secondary)
                    
                    Button(getString(.newConversation)) {
                        navigationCoordinator.push(MessageScreen.createConversation)
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(.gedPrimary)
                }
                .padding(.top, GedSpacing.large)
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(conversationViewModel.conversationsMap.sortedByDate(), id: \.id) { conversation in
                            GetConversationItem(
                                conversation: conversation,
                                onClick: {
                                    navigationCoordinator.push(MessageScreen.chat(conversation: conversation))
                                },
                                onLongClick: {
                                    selectedConversation = conversation
                                    showBottomSheet = true
                                }
                            )
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
                    .onClick(isClicked: $isBottomSheetItemClicked) {
                        showBottomSheet = false
                        showDeleteAlert = true
                    }
                    .presentationDetents([.fraction(0.10)])
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
                Button(
                    action: { navigationCoordinator.push(MessageScreen.createConversation) }
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
        .onAppear {
            tabBarVisibility.show = true
        }
    }
}

private struct GetConversationItem: View {
    private let conversation: ConversationUI
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
            if !lastMessage.isRead && lastMessage.senderId == conversation.interlocutor.id {
                UnreadConversationItem(
                    conversationUI: conversation,
                    onClick: onClick,
                    onLongClick: onLongClick
                )
            } else {
                ReadConversationItem(
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
    struct ConversationView_Preview: View {
        @StateObject var navigationCoordinator = CommonDependencyInjectionContainer.shared.resolve(NavigationCoordinator.self)
        let mockConversationViewModel = MessageDependencyInjectionContainer.shared.resolveWithMock().resolve(ConversationViewModel.self)!
        let mockCreateConversationViewModel = MessageDependencyInjectionContainer.shared.resolveWithMock().resolve(CreateConversationViewModel.self)!
        let tabBarVisibility = CommonDependencyInjectionContainer.shared.resolve(TabBarVisibility.self)
        
        var body: some View {
            NavigationStack(path: $navigationCoordinator.path) {
                ConversationView()
                    .environmentObject(mockConversationViewModel)
                    .navigationDestination(for: MessageScreen.self) { screen in
                        if case .chat(let conversation) = screen {
                            ChatView(conversation: conversation)
                                .environmentObject(
                                    MessageDependencyInjectionContainer.shared.resolveWithMock().resolve(ChatViewModel.self, argument: conversation)!
                                )
                        } else if case .createConversation = screen {
                            CreateConversationView()
                                .environmentObject(mockCreateConversationViewModel)
                        }
                    }
            }
            .environmentObject(navigationCoordinator)
            .environmentObject(tabBarVisibility)
        }
    }
    
    return ConversationView_Preview()
}
