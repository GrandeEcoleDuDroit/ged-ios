import SwiftUI

struct ConversationView: View {
    @EnvironmentObject private var conversationViewModel: ConversationViewModel
    @State private var selectedConversation: ConversationUI? = nil
    @State private var showCreateConversationView: Bool = false
    
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
                                onClick: { selectedConversation = conversation }
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
                                    selection: $selectedConversation,
                                    label: { EmptyView() }
                                )
                                .hidden()
                            )
                        }
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
    }
}

struct GetConversationItem: View {
    private var conversation: ConversationUI
    private let onClick: () -> Void
    
    init(conversation: ConversationUI, onClick: @escaping () -> Void) {
        self.conversation = conversation
        self.onClick = onClick
    }
    
    var body: some View {
        if let lastMessage = conversation.lastMessage {
            if lastMessage.isRead {
                ReadConversationItem(conversationUI: conversation, onClick: onClick)
            } else {
                UnreadConversationItem(conversationUI: conversation, onClick: onClick)
            }
        }
        else {
            EmptyConversationItem(conversationUI: conversation, onClick: onClick)
        }
    }
}

#Preview {
    NavigationView {
        ConversationView()
            .environmentObject(DependencyContainer.shared.mockConversationViewModel)
    }
}
