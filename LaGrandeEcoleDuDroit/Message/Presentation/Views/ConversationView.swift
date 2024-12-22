import SwiftUI

struct ConversationView: View {
    @EnvironmentObject private var conversationViewModel: ConversationViewModel
    @State private var navigateToCreateAnnouncementView: Bool = false
    @State private var selectedConversation: ConversationUI? = nil
    
    var body: some View {
        ZStack {
            if conversationViewModel.conversationsMap.isEmpty {
                VStack {
                    Text(getString(.startConversation))
                        .font(.bodyLarge)
                        .foregroundColor(.secondary)
                    
                    NavigationLink(
                        destination: CreateConversationView()
                            .environmentObject(DependencyContainer.shared.createConversationViewModel)
                    ) {
                        Text(getString(.newConversation))
                            .fontWeight(.semibold)
                            .foregroundStyle(.gedPrimary)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle(getString(.messages))
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(
                    destination:
                        CreateConversationView().environmentObject(DependencyContainer.shared.createConversationViewModel),
                    isActive: $navigateToCreateAnnouncementView
                ) {
                    Button(
                        action: { navigateToCreateAnnouncementView = true },
                        label: { Image(systemName: "plus") }
                    )
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
