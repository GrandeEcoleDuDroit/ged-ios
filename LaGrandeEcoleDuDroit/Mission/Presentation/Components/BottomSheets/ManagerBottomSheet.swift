import SwiftUI

struct SelectManagerBottomSheet: View {
    let users: [User]
    let selectedManagers: Set<User>
    let userQuery: String
    let onUserQueryChange: (String) -> Void
    let onSaveClick: ([User]) -> Void
    
    @State private var currentSelectedManagers: Set<User>
    @State private var saveEnabled: Bool = false
    
    init(
        users: [User],
        selectedManagers: Set<User>,
        userQuery: String,
        onUserQueryChange: @escaping (String) -> Void,
        onSaveClick: @escaping ([User]) -> Void
    ) {
        self.users = users
        self.selectedManagers = selectedManagers
        self.userQuery = userQuery
        self.onUserQueryChange = onUserQueryChange
        self.onSaveClick = onSaveClick
        self.currentSelectedManagers = selectedManagers
    }
    
    var body: some View {
        VStack(spacing: .zero) {
            SearchBar(query: userQuery, onQueryChange: onUserQueryChange)
                .padding(.horizontal)
            
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
            .listRowBackground(Color.background)
            .listStyle(.plain)
        }
        .padding(.top)
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
    SelectManagerBottomSheet(
        users: usersFixture,
        selectedManagers: [userFixture],
        userQuery: "",
        onUserQueryChange: { _ in },
        onSaveClick: { _ in }
    )
}
