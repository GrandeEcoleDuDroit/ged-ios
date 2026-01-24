import SwiftUI

struct SelectManagerDestination: View {
    let onSaveManagersClick: ([User]) -> Void
    let onCancelClick: () -> Void

    @StateObject private var viewModel: SelectManagerViewModel
    
    init(
        users: [User],
        selectedManagers: Set<User>,
        onSaveManagersClick: @escaping ([User]) -> Void,
        onCancelClick: @escaping () -> Void
    ) {
        _viewModel = StateObject(
            wrappedValue: MissionMainThreadInjector.shared.resolve(
                SelectManagerViewModel.self,
                arguments: users, selectedManagers
            )!
        )
        self.onSaveManagersClick = onSaveManagersClick
        self.onCancelClick = onCancelClick
    }
    
    var body: some View {
        NavigationStack {
            SelectManagerView(
                users: viewModel.uiState.users,
                selectedManagers: viewModel.uiState.selectedManagers,
                userQuery: $viewModel.uiState.userQuery,
                saveEnabled: viewModel.uiState.saveEnabled,
                onManagerClick: viewModel.onManagerClick,
                onUserQueryChange: viewModel.onUserQueryChange,
                onSaveManagersClick: onSaveManagersClick,
                onCancelClick: onCancelClick
            )
        }
    }
}

private struct SelectManagerView: View {
    let users: [User]
    let selectedManagers: Set<User>
    @Binding var userQuery: String
    let saveEnabled: Bool
    let onManagerClick: (User) -> Void
    let onUserQueryChange: (String) -> Void
    let onSaveManagersClick: ([User]) -> Void
    let onCancelClick: () -> Void
    
    var body: some View {
        List {
            if users.isEmpty {
                Text(stringResource(.noUsersFound))
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(.informationText)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
            } else {
                ForEach(users) { user in
                    Button(action: { onManagerClick(user) }) {
                        HStack {
                            CheckBox(checked: selectedManagers.contains(user))
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
            ToolbarItem(placement: .cancellationAction) {
                Button(stringResource(.cancel), action: onCancelClick)
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Button(action: { onSaveManagersClick(selectedManagers.toList()) }) {
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
        .interactiveDismissDisabled(true)
    }
}

#Preview {
    NavigationStack {
        SelectManagerView(
            users: usersFixture,
            selectedManagers: [userFixture],
            userQuery: .constant(""),
            saveEnabled: false,
            onManagerClick: { _ in },
            onUserQueryChange: { _ in },
            onSaveManagersClick: { _ in },
            onCancelClick: {}
        )
    }.environment(\.managedObjectContext, GedDatabaseContainer.preview.container.viewContext)
}
