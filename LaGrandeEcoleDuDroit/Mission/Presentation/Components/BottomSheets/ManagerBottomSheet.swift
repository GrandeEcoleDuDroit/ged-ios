import SwiftUI

struct SelectManagerBottomSheet: View {
    let users: [User]
    let selectedManagers: Set<User>
    let userQuery: String
    let onUserQueryChange: (String) -> Void
    let onSaveManagersClick: ([User]) -> Void
    let onCancelClick: () -> Void
    
    @State private var currentSelectedManagers: Set<User>
    @State private var saveEnabled: Bool = false
    
    init(
        users: [User],
        selectedManagers: Set<User>,
        userQuery: String,
        onUserQueryChange: @escaping (String) -> Void,
        onSaveManagersClick: @escaping ([User]) -> Void,
        onCancelClick: @escaping () -> Void
    ) {
        self.users = users
        self.selectedManagers = selectedManagers
        self.userQuery = userQuery
        self.onUserQueryChange = onUserQueryChange
        self.onSaveManagersClick = onSaveManagersClick
        self.currentSelectedManagers = selectedManagers
        self.onCancelClick = onCancelClick
    }
    
    var body: some View {
        NavigationStack {
            List {
                if users.isEmpty {
                    Text(stringResource(.noUser))
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(.informationText)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets())
                } else {
                    ForEach(users) { user in
                        let selected = currentSelectedManagers.contains(user)
                        
                        SelectableManagerItem(
                            user: user,
                            selected: selected,
                            onUserClick: {
                                if selected {
                                    currentSelectedManagers.remove(user)
                                } else {
                                    currentSelectedManagers.insert(user)
                                }
                                
                                saveEnabled =
                                !currentSelectedManagers.isEmpty &&
                                currentSelectedManagers != selectedManagers
                            }
                        )
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets())
                    }
                }
            }
            .scrollIndicators(.hidden)
            .listStyle(.plain)
            .searchable(
                text: Binding(
                    get: { userQuery },
                    set: onUserQueryChange
                ),
                placement: .navigationBarDrawer(displayMode: .always)
            )
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: onCancelClick) {
                        Text(stringResource(.cancel))
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { onSaveManagersClick(currentSelectedManagers.toList()) }) {
                        if !saveEnabled {
                            Text(stringResource(.save))
                        } else {
                            Text(stringResource(.save))
                                .foregroundColor(.gedPrimary)
                        }
                    }
                    .disabled(!saveEnabled)
                }
            }
        }
    }
}

private struct SelectableManagerItem: View {
    let user: User
    let selected: Bool
    let onUserClick: () -> Void
    
    var body: some View {
        Button(action: onUserClick) {
            HStack {
                CheckBox(checked: selected)
                
                MissionUserItem(
                    user: user,
                    imageScale: 0.5
                )
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    NavigationStack {
        SelectManagerBottomSheet(
            users: usersFixture,
            selectedManagers: [userFixture],
            userQuery: "",
            onUserQueryChange: { _ in },
            onSaveManagersClick: { _ in },
            onCancelClick: {}
        )
    }.environment(\.managedObjectContext, GedDatabaseContainer.preview.container.viewContext)
}
