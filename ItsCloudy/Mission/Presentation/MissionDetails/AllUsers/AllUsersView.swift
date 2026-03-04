import SwiftUI

struct AllUsersDestination: View {
    let onCancelClick: () -> Void
    
    @StateObject private var viewModel: AllUsersViewModel
    @State private var path: [AllUsersSubDestination] = []

    init(
        users: [User],
        onCancelClick: @escaping () -> Void
    ) {
        _viewModel = StateObject(
            wrappedValue: MissionMainThreadInjector.shared.resolve(
                AllUsersViewModel.self,
                arguments: users
            )!
        )
        self.onCancelClick = onCancelClick
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            AllUsersView(
                users: viewModel.uiState.users,
                onUserQueryChange: viewModel.onUserQueryChange,
                onUserClick: { path.append(.userProfile($0)) },
                onCancelClick: onCancelClick
            )
            .navigationDestination(for: AllUsersSubDestination.self) { destination in
                switch destination {
                    case let .userProfile(user):
                        UserDestination(user: user)
                }
            }
        }
    }
}

private enum AllUsersSubDestination: Hashable {
    case userProfile(User)
}

struct AllUsersView: View {
    let users: [User]
    let onUserQueryChange: (String) -> Void
    let onUserClick: (User) -> Void
    let onCancelClick: () -> Void

    @State private var isSearchPresented: Bool = false
    @State private var userQuery: String = ""
    
    var body: some View {
        List(users) { user in
            Button(action: { onUserClick(user) }) {
                UserItem(user: user)
            }
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets())
        }
        .scrollDismissesKeyboard(.interactively)
        .listStyle(.plain)
        .searchable(text: $userQuery, placement: .navigationBarDrawer(displayMode: .always))
        .onChange(of: userQuery, perform: onUserQueryChange)
        .navigationTitle(stringResource(.allUsers))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(stringResource(.cancel), action: onCancelClick)
            }
        }
        .interactiveDismissDisabled(true)
    }
}

#Preview {
    NavigationStack {
        AllUsersView(
            users: usersFixture,
            onUserQueryChange: { _ in },
            onUserClick: { _ in },
            onCancelClick: { }
        )
    }.environment(\.managedObjectContext, GedDatabaseContainer.preview.container.viewContext)
}
