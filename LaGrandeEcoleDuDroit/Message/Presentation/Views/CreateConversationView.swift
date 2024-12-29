import SwiftUI

struct CreateConversationView: View {
    @EnvironmentObject private var createConversationViewModel: CreateConversationViewModel
    @EnvironmentObject private var tabBarVisibility: TabBarVisibility
    @EnvironmentObject private var coordinator: MessageNavigationCoordinator
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
                    Text(getString(.noUserFound))
                        .font(.bodyLarge)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical)
                } else {
                    ScrollView {
                        ForEach(createConversationViewModel.users, id: \.id) { user in
                            NavigationLink(value: user) {
                                UserItem(user: user)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
            }
        }
        .navigationDestination(for: User.self) { user in
            let conversation = createConversationViewModel.generateConversation(interlocutor: user)
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
            .environmentObject(DependencyContainer.shared.mockCreateConversationViewModel)
            .environmentObject(TabBarVisibility())
            .environmentObject(MessageNavigationCoordinator())
    }
}
