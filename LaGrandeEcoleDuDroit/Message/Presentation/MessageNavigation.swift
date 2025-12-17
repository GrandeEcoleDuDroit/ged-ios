import SwiftUI

struct MessageNavigation: View {
    @StateObject private var viewModel = MessageMainThreadInjector.shared.resolve(MessageNavigationViewModel.self)
    
    var body: some View {
        NavigationStack(path: $viewModel.path) {
            ConversationDestination(
                onConversationClick: { conversation in
                    viewModel.path.append(.chat(conversation: conversation))
                }
            )
            .background(.appBackground)
            .toolbar(viewModel.path.isEmpty ? .visible : .hidden, for: .tabBar)
            .navigationDestination(for: MessageRoute.self) { route in
                switch route {
                    case let .chat(conversation):
                        ChatDestination(
                            conversation: conversation,
                            onBackClick: { viewModel.path.removeAll() },
                            onInterlocutorClick: { user in
                                viewModel.path.append(.interlocutor(user: user))
                            }
                        )
                        .background(.appBackground)
                        
                    case let .interlocutor(user):
                        UserDestination(user: user)
                            .background(.appBackground)
                }
            }
        }
    }
}
