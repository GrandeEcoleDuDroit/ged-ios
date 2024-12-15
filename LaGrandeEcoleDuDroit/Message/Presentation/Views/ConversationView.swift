import SwiftUI

struct ConversationView: View {
    @EnvironmentObject private var conversationViewModel: ConversationViewModel
    @State private var navigateToCreateAnnouncementView: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(conversationViewModel.conversationsMap.sortedByDate(), id: \.id) { conversation in
                    if let lastMessage = conversation.lastMessage {
                        if lastMessage.isRead {
                            ReadConversationItem(conversationUI: conversation, onClick: {})
                        } else {
                            UnreadConversationItem(conversationUI: conversation, onClick: {})
                        }
                    }
                    else {
                        EmptyConversationItem(conversationUI: conversation, onClick: {})
                    }
                }
            }
        }
        .navigationTitle(getString(gedString: GedString.messages))
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
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


#Preview {
    NavigationView {
        ConversationView()
            .environmentObject(DependencyContainer.shared.mockConversationViewModel)
    }
}
