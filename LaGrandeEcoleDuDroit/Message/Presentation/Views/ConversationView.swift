import SwiftUI

struct ConversationView: View {
    @EnvironmentObject private var conversationViewModel: ConversationViewModel
    @State private var navigateToCreateAnnouncementView: Bool = false
    
    var body: some View {
        ScrollView {
            ForEach($conversationViewModel.conversations, id: \.id) { $conversation in
                if conversation.message.isRead {
                    ReadConversationItem(conversation: .constant(conversation), onClick: {})
                } else {
                    UnreadConversationItem(conversation: .constant(conversation), onClick: {})
                }
            }
        }
        .navigationTitle(getString(gedString: GedString.messages))
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                NavigationLink(
                    destination: CreateConversationView().environmentObject(DependencyContainer.shared.createConversationViewModel),
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
