import SwiftUI
import Combine

struct ConversationDestination: View {
    let onCreateConversationClick: () -> Void
    let onConversationClick: (ConversationUi) -> Void
    
    @StateObject private var viewModel = MessageInjection.shared.resolve(ConversationViewModel.self)
    @State private var showErrorAlert: Bool = false
    @State private var errorMessage: String = ""
    
    var body: some View {
        ConversationView(
            conversationsUi: viewModel.uiState.conversations,
            onCreateConversationClick: onCreateConversationClick,
            onConversationClick: onConversationClick,
            onDeleteConversationClick: viewModel.deleteConversation
        )
        .navigationTitle(getString(.messages))
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(
                    action: onCreateConversationClick,
                    label: { Image(systemName: "plus") }
                )
            }
        }
        .onReceive(viewModel.$event) { event in
            if let errorEvent = event as? ErrorEvent {
                errorMessage = errorEvent.message
                showErrorAlert = true
            }
        }
        .alert(
            errorMessage,
            isPresented: $showErrorAlert
        ) {
            Button(
                getString(.ok),
                action: { showErrorAlert = false }
            )
        }
    }
}

private struct ConversationView: View {
    let conversationsUi: [ConversationUi]?
    let onCreateConversationClick: () -> Void
    let onConversationClick: (ConversationUi) -> Void
    let onDeleteConversationClick: (Conversation) -> Void
    
    @State private var selectedConversation: ConversationUi? = nil
    @State private var showBottomSheet: Bool = false
    @State private var isBottomSheetItemClicked: Bool = false
    @State private var showDeleteAlert: Bool = false
    
    var body: some View {
        ZStack {
            if let conversations = conversationsUi {
                if conversations.isEmpty {
                    VStack {
                        Text(getString(.noConversation))
                            .font(.callout)
                            .foregroundColor(.secondary)
                        
                        Button(
                            getString(.newConversation),
                            action: onCreateConversationClick
                        )
                        .fontWeight(.semibold)
                        .font(.callout)
                        .foregroundColor(.gedPrimary)
                    }
                    .padding(.top, GedSpacing.medium)
                    .padding(.horizontal, GedSpacing.extraSmall)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(conversations, id: \.id) { conversation in
                                ConversationItem(
                                    conversation: conversation,
                                    onClick: { onConversationClick(conversation) },
                                    onLongClick: {
                                        selectedConversation = conversation
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
                                text: Text(getString(.delete))
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
        .alert(
            getString(.deleteConversationAlertMessage),
            isPresented: $showDeleteAlert
        ) {
            Button(getString(.cancel), role: .cancel) {
                showDeleteAlert = false
            }
            Button(getString(.delete), role: .destructive) {
                if let conversation = selectedConversation {
                    onDeleteConversationClick(conversation.toConversation())
                }
                showDeleteAlert = false
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
