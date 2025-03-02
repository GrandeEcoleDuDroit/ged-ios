import SwiftUI

struct CreateConversationView: View {
    @StateObject private var createConversationViewModel = MessageInjection.shared.resolve(CreateConversationViewModel.self)
    @EnvironmentObject private var tabBarVisibility: TabBarVisibility
    @EnvironmentObject private var navigationCoordinator: NavigationCoordinator
    @State private var errorMessage: String = ""
    @State private var isClicked: Bool = false
    @State private var isLoading: Bool = false
    @State private var selectedUser: User? = nil
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            else {
                if createConversationViewModel.users.isEmpty {
                    Text(getString(.userNotFoundError))
                        .font(.bodyLarge)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical)
                } else {
                    ScrollView {
                        ForEach(createConversationViewModel.users, id: \.id) { user in
                            let conversation = createConversationViewModel.generateConversation(interlocutor: user)
                            UserItem(user: user) {
                                navigationCoordinator.push(MessageScreen.chat(conversation: conversation))
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(getString(.newConversation))
        .navigationBarTitleDisplayMode(.inline)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .onReceive(createConversationViewModel.$conversationState) { state in
            switch state {
                case .loading:
                    isLoading = true
                case .error(let message):
                    errorMessage = message
                    isLoading = false
                default:
                    errorMessage = ""
                    isLoading = false
            }
        }
        .searchable(
            text: $createConversationViewModel.searchUser,
            placement: .navigationBarDrawer(displayMode: .always)
        )
    }
}

#Preview {
    NavigationStack {
        CreateConversationView()
            .environmentObject(TabBarVisibility())
            .environmentObject(NavigationCoordinator())
    }
}
