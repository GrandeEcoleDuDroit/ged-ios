import SwiftUI

struct ConversationDestination: View {
    let onCreateConversationClick: () -> Void
    let onConversationClick: (ConversationUi) -> Void
    
    @StateObject private var viewModel = MessageMainThreadInjector.shared.resolve(ConversationViewModel.self)
    @State private var showErrorAlert: Bool = false
    @State private var errorMessage: String = ""
    
    var body: some View {
        ConversationView(
            conversationsUi: viewModel.uiState.conversations,
            onCreateConversationClick: onCreateConversationClick,
            onConversationClick: onConversationClick,
            onDeleteConversationClick: viewModel.deleteConversation
        )
        .onReceive(viewModel.$event) { event in
            if let errorEvent = event as? ErrorEvent {
                errorMessage = errorEvent.message
                showErrorAlert = true
            }
        }
        .alert(
            errorMessage,
            isPresented: $showErrorAlert,
            actions: {
                Button(stringResource(.ok)) {
                    showErrorAlert = false
                }
            }
        )
    }
}

private struct ConversationView: View {
    let conversationsUi: [ConversationUi]?
    let onCreateConversationClick: () -> Void
    let onConversationClick: (ConversationUi) -> Void
    let onDeleteConversationClick: (Conversation) -> Void
    
    @State private var showDeleteAlert: Bool = false
    @State private var clickedConversationUi: ConversationUi?
    
    var body: some View {
        ZStack {
            if let conversationsUi {
                if conversationsUi.isEmpty {
                    VStack {
                        Text(stringResource(.noConversation))
                            .foregroundStyle(.informationText)
                        
                        Button(
                            stringResource(.newConversation),
                            action: onCreateConversationClick
                        )
                        .fontWeight(.semibold)
                        .foregroundStyle(.gedPrimary)
                    }
                    .padding(.top, Dimens.mediumPadding)
                    .padding(.horizontal, Dimens.mediumPadding)
                } else {
                    List(conversationsUi) { conversationUi in
                        Button(action: { onConversationClick(conversationUi) }) {
                            ConversationItem(conversationUi: conversationUi)
                                .simultaneousGesture(
                                    LongPressGesture()
                                        .onEnded { _ in
                                            let generator = UIImpactFeedbackGenerator(style: .medium)
                                            generator.impactOccurred()
                                            clickedConversationUi = conversationUi
                                        }
                                )
                        }
                        .buttonStyle(ClickStyle())
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(.init())
                    }
                    .scrollIndicators(.hidden)
                    .listStyle(.plain)
                }
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.background)
        .navigationTitle(stringResource(.messages))
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(
                    action: onCreateConversationClick,
                    label: { Image(systemName: "plus") }
                )
            }
        }
        .alert(
            stringResource(.deleteConversationAlertTitle),
            isPresented: $showDeleteAlert,
            presenting: clickedConversationUi,
            actions: { conversationUi in
                Button(stringResource(.cancel), role: .cancel) {
                    showDeleteAlert = false
                }
                Button(stringResource(.delete), role: .destructive) {
                    onDeleteConversationClick(conversationUi.toConversation())
                    showDeleteAlert = false
                }
            },
            message: { _ in
                Text(stringResource(.deleteConversationAlertMessage))
            }
        )
        .sheet(item: $clickedConversationUi) { conversationUi in
            BottomSheetContainer(fraction: 0.10) {
                ClickableTextItem(
                    icon: Image(systemName: "trash"),
                    text: Text(stringResource(.delete))
                ) {
                    clickedConversationUi = conversationUi
                    showDeleteAlert = true
                }
                .foregroundStyle(.red)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ConversationView(
            conversationsUi: conversationsUiFixture,
            onCreateConversationClick: {},
            onConversationClick: {_ in},
            onDeleteConversationClick: {_ in}
        )
    }
}
