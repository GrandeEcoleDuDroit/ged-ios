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
                Button(
                    stringResource(.ok),
                    action: { showErrorAlert = false }
                )
            }
        )
    }
}

private struct ConversationView: View {
    let conversationsUi: [ConversationUi]?
    let onCreateConversationClick: () -> Void
    let onConversationClick: (ConversationUi) -> Void
    let onDeleteConversationClick: (Conversation) -> Void
    
    @State private var clickedConversation: ConversationUi? = nil
    @State private var showBottomSheet: Bool = false
    @State private var isBottomSheetItemClicked: Bool = false
    @State private var showDeleteAlert: Bool = false
    
    var body: some View {
        ZStack {
            if let conversationsUi {
                if conversationsUi.isEmpty {
                    VStack {
                        Text(stringResource(.noConversation))
                            .font(.callout)
                            .foregroundColor(.secondary)
                        
                        Button(
                            stringResource(.newConversation),
                            action: onCreateConversationClick
                        )
                        .fontWeight(.semibold)
                        .font(.callout)
                        .foregroundColor(.gedPrimary)
                    }
                    .padding(.top, Dimens.mediumPadding)
                    .padding(.horizontal, Dimens.extraSmallPadding)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(conversationsUi) { conversationUi in
                                ConversationItem(
                                    conversationUi: conversationUi,
                                    onClick: { onConversationClick(conversationUi) },
                                    onLongClick: {
                                        clickedConversation = conversationUi
                                        showBottomSheet = true
                                    }
                                )
                            }
                        }
                    }
                    .sheet(isPresented: $showBottomSheet) {
                        BottomSheetContainer(fraction: 0.10) {
                            ClickableTextItem(
                                icon: Image(systemName: "trash"),
                                text: Text(stringResource(.delete))
                            ) {
                                showBottomSheet = false
                                showDeleteAlert = true
                            }
                            .foregroundStyle(.red)
                        }
                    }
                }
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
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
            actions: {
                Button(stringResource(.cancel), role: .cancel) {
                    showDeleteAlert = false
                }
                Button(stringResource(.delete), role: .destructive) {
                    if let clickedConversation {
                        onDeleteConversationClick(clickedConversation.toConversation())
                    }
                    showDeleteAlert = false
                }
            },
            message: { Text(stringResource(.deleteConversationAlertMessage)) }
        )
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
        .background(Color.background)
    }
}
