import SwiftUI

struct CreateConversationDestination: View {
    let onCreateConversationClick: (Conversation) -> Void
    
    @StateObject private var viewModel = MessageMainThreadInjector.shared.resolve(CreateConversationViewModel.self)
    @State private var errorMessage: String = ""
    
    var body: some View {
        CreateConversationView(
            users: viewModel.uiState.users,
            loading: viewModel.uiState.loading,
            userQuery: viewModel.uiState.query,
            onQueryChange: viewModel.onQueryChange,
            onUserClick: { user in
                Task {
                    if let conversation = await viewModel.getConversation(interlocutor: user) {
                        onCreateConversationClick(conversation)
                    }
                }
            }
        )
    }
}

private struct CreateConversationView: View {
    let users: [User]
    let loading: Bool
    let userQuery: String
    let onQueryChange: (String) -> Void
    let onUserClick: (User) -> Void
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVStack(spacing: .zero) {
                    if loading {
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    }
                    else {
                        if users.isEmpty {
                            Text(stringResource(.userNotFound))
                                .foregroundColor(.informationText)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical)
                        } else {
                            ForEach(users, id: \.id) { user in
                                Button(action: { onUserClick(user) }) {
                                    UserItem(user: user)
                                        .contentShape(Rectangle())
                                }
                                .buttonStyle(ClickStyle())
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(stringResource(.newConversation))
        .navigationBarTitleDisplayMode(.inline)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .searchable(
            text: Binding(
                get: { userQuery },
                set: onQueryChange
            ),
            placement: .navigationBarDrawer(displayMode: .always)
        )
    }
}

#Preview {
    NavigationStack {
        CreateConversationView(
            users: usersFixture,
            loading: false,
            userQuery: "",
            onQueryChange: {_ in },
            onUserClick: {_ in }
        )
        .background(.appBackground)
    }
    .environment(\.managedObjectContext, GedDatabaseContainer.preview.container.viewContext)
}
