import SwiftUI

struct CreateConversationDestination: View {
    let onUserClick: (User) -> Void
    let onCancelClick: () -> Void
    
    @StateObject private var viewModel = MessageMainThreadInjector.shared.resolve(CreateConversationViewModel.self)
    @State private var errorMessage: String = ""
    
    var body: some View {
        CreateConversationView(
            users: viewModel.uiState.users,
            onUserQueryChange: { [weak viewModel] query in
                viewModel?.onUserQueryChange(query)
            },
            onUserClick: onUserClick,
            onCancelClick: onCancelClick
        )
    }
}

private struct CreateConversationView: View {
    let users: [User]?
    let onUserQueryChange: (String) -> Void
    let onUserClick: (User) -> Void
    let onCancelClick: () -> Void
    
    @State private var selectedUser: User?
    @State private var query: String = ""

    var body: some View {
        List {
            if let users {
                if users.isEmpty {
                    Text(stringResource(.noUserFound))
                        .foregroundStyle(.informationText)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .listRowSeparator(.hidden)
                } else {
                    ForEach(users) { user in
                        Button(action: { onUserClick(user) }) {
                            UserItem(user: user)
                                .contentShape(Rectangle())
                        }
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets())
                    }
                }
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
            }
        }
        .listStyle(.plain)
        .navigationTitle(stringResource(.newConversation))
        .navigationBarTitleDisplayMode(.inline)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .searchable(
            text: $query,
            placement: .navigationBarDrawer(displayMode: .always)
        )
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(stringResource(.cancel)) {
                    onCancelClick()
                }
            }
        }
        .onChange(of: query) {
            onUserQueryChange($0)
        }
    }
}

#Preview {
    NavigationStack {
        CreateConversationView(
            users: [],
            onUserQueryChange: {_ in },
            onUserClick: {_ in },
            onCancelClick: {}
        )
    }
    .environment(\.managedObjectContext, GedDatabaseContainer.preview.container.viewContext)
}
