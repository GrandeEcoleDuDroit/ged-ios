import SwiftUI

struct ConversationDestination: View {
    let onCreateConversationClick: () -> Void
    let onConversationClick: (ConversationUi) -> Void
    
    @StateObject private var viewModel = MessageMainThreadInjector.shared.resolve(ConversationViewModel.self)
    @State private var showErrorAlert: Bool = false
    @State private var errorMessage: String = ""
    
    var body: some View {
        if let conversationsUi = viewModel.uiState.conversationsUi {
            ConversationView(
                conversationsUi: conversationsUi,
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
        } else {
            FullProgressView()
        }
    }
}

private struct ConversationView: View {
    let conversationsUi: [ConversationUi]
    let onCreateConversationClick: () -> Void
    let onConversationClick: (ConversationUi) -> Void
    let onDeleteConversationClick: (Conversation) -> Void
    
    @State private var showDeleteAlert: Bool = false
    @State private var sheetConversationUi: ConversationUi?
    @State private var alertConversationUi: ConversationUi?
    
    var body: some View {
        PlainTableView(
            modifier: PlainTableModifier(
                backgroundColor: .appBackground,
                onRowLongClick: { sheetConversationUi = $0 }
            ),
            values: conversationsUi,
            onRowClick: { onConversationClick($0) },
            emptyContent: { emptyConversationsView },
            content: { ConversationItem(conversationUi: $0) }
        )
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
            presenting: alertConversationUi,
            actions: { conversationUi in
                Button(stringResource(.cancel), role: .cancel) {
                    showDeleteAlert = false
                    alertConversationUi = nil
                }
                
                Button(stringResource(.delete), role: .destructive) {
                    showDeleteAlert = false
                    alertConversationUi = nil
                    onDeleteConversationClick(conversationUi.toConversation())
                }
            },
            message: { _ in
                Text(stringResource(.deleteConversationAlertMessage))
            }
        )
        .sheet(item: $sheetConversationUi) { conversationUi in
            BottomSheetContainer(fraction: Dimens.bottomSheetFraction(itemCount: 1)) {
                ClickableTextItem(
                    icon: Image(systemName: "trash"),
                    text: Text(stringResource(.delete))
                ) {
                    sheetConversationUi = nil
                    alertConversationUi = conversationUi
                    showDeleteAlert = true
                }
                .foregroundStyle(.red)
            }
        }
    }
    
    private var emptyConversationsView: some View {
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
        .frame(maxWidth: .infinity, alignment: .center)
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
    .environment(\.managedObjectContext, GedDatabaseContainer.preview.container.viewContext)
}
