import SwiftUI

struct ConversationDestination: View {
    let onCreateConversationClick: () -> Void
    let onConversationClick: (ConversationUi) -> Void
    
    @StateObject private var viewModel = MessageMainThreadInjector.shared.resolve(ConversationViewModel.self)
    @State private var showErrorAlert: Bool = false
    @State private var errorMessage: String = ""
    
    var body: some View {
        ConversationView(
            conversationsUi: conversationsUiFixture,
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
        VStack {
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
                    List {
                        ForEach(conversationsUi) { conversationUi in
                            Button(
                                action: { onConversationClick(conversationUi) },
                                label: {
                                    ConversationItem(
                                        conversationUi: conversationUi,
                                        onClick: { onConversationClick(conversationUi) },
                                        onLongClick: {
                                            clickedConversation = conversationUi
                                            showBottomSheet = true
                                        }
                                    )
                                }
                            )
                            .buttonStyle(ClickStyle())
                            .listRowSeparator(.hidden)
                            .listRowInsets(.init())
                            .listRowBackground(Color.background)
                        }
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
