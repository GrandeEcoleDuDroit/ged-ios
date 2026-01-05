import SwiftUI

struct SelectManagerView: View {
    let users: [User]
    let selectedManagers: Set<User>
    let onUserQueryChange: (String) -> Void
    let onSaveManagersClick: ([User]) -> Void
    
    @State private var currentSelectedManagers: Set<User>
    @State private var saveEnabled: Bool = false
    @State private var userQuery: String = ""
    
    init(
        users: [User],
        selectedManagers: Set<User>,
        onUserQueryChange: @escaping (String) -> Void,
        onSaveManagersClick: @escaping ([User]) -> Void
    ) {
        self.users = users
        self.selectedManagers = selectedManagers
        self.onUserQueryChange = onUserQueryChange
        self.onSaveManagersClick = onSaveManagersClick
        self.currentSelectedManagers = selectedManagers
    }
    
    var body: some View {
        List {
            if users.isEmpty {
                Text(stringResource(.noUserFound))
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(.informationText)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
            } else {
                ForEach(users) { user in
                    let selected = currentSelectedManagers.contains(user)
                    
                    Button(
                        action: {
                            if selected {
                                currentSelectedManagers.remove(user)
                            } else {
                                currentSelectedManagers.insert(user)
                            }
                            
                            saveEnabled =
                                !currentSelectedManagers.isEmpty &&
                                    currentSelectedManagers != selectedManagers
                        }
                    ) {
                        HStack {
                            CheckBox(checked: selected)
                            MissionUserItem(
                                user: user,
                                imageScale: 0.5
                            )
                        }
                        .contentShape(.rect)
                        .padding(.leading)
                    }
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
                }
            }
        }
        .listStyle(.plain)
        .searchable(
            text: $userQuery,
            placement: .navigationBarDrawer(displayMode: .always)
        )
        .onChange(of: userQuery, perform: onUserQueryChange)
        .navigationTitle(stringResource(.selectManagers))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(action: { onSaveManagersClick(currentSelectedManagers.toList()) }) {
                    if saveEnabled {
                        Text(stringResource(.save))
                            .foregroundColor(.gedPrimary)
                    } else {
                        Text(stringResource(.save))
                    }
                }
                .disabled(!saveEnabled)
            }
        }
    }
}

#Preview {
    NavigationStack {
        SelectManagerView(
            users: usersFixture,
            selectedManagers: [userFixture],
            onUserQueryChange: { _ in },
            onSaveManagersClick: { _ in }
        )
    }.environment(\.managedObjectContext, GedDatabaseContainer.preview.container.viewContext)
}
