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
    @State private var sheetConversationUi: ConversationUi?
    @State private var alertConversationUi: ConversationUi?
    
    var body: some View {
        List {
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
                    .frame(maxWidth: .infinity, alignment: .center)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                } else {
                    ForEach(conversationsUi) { conversationUi in
                        Button(action: { onConversationClick(conversationUi) }) {
                            ConversationItem(conversationUi: conversationUi)
                                .simultaneousGesture(
                                    LongPressGesture()
                                        .onEnded { _ in
                                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                            sheetConversationUi = conversationUi
                                        }
                                )
                                .contentShape(.rect)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(ClickStyle())
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets())
                    }
                }
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
            }
        }
        .scrollIndicators(.hidden)
        .listStyle(.plain)
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
    .environment(\.managedObjectContext, GedDatabaseContainer.preview.container.viewContext)
}
