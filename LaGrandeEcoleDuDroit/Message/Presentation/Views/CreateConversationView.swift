import SwiftUI

struct CreateConversationView: View {
    @EnvironmentObject private var createConversationViewModel: CreateConversationViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var errorMessage: String = ""
    @State private var showLoading: Bool = false
    @State private var background: Color = Color.white
    @State private var isClicked: Bool = false

    var body: some View {
        ScrollView {
            if createConversationViewModel.users.isEmpty {
                Text(getString(gedString: GedString.user_not_found))
            } else {
                ForEach($createConversationViewModel.users) { $user in
                    UserItem(user: user, onClick: {})
                }
            }
        }
        .navigationTitle(getString(gedString: GedString.new_message))
        .navigationBarTitleDisplayMode(.inline)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .onReceive(createConversationViewModel.$conversationState) { state in
            switch state {
            case .error(let message):
                errorMessage = message
            default:
                errorMessage = ""
            }
        }
    }
}

#Preview {
    NavigationView {
        CreateConversationView()
            .environmentObject(DependencyContainer.shared.mockCreateConversationViewModel)
    }
}
