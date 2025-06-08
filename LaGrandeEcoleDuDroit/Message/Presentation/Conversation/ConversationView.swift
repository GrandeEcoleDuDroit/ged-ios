import SwiftUI

struct ConversationDestination: View {
    let onCreateConversationClick: () -> Void
    let onConversationClick: (ConversationUi) -> Void
    
    @StateObject private var viewModel = MessageInjection.shared.resolve(ConversationViewModel.self)
    @State private var showErrorAlert: Bool = false
    @State private var errorMessage: String = ""
    
    var body: some View {
        ConversationView(
            conversations: viewModel.uiState.conversations,
            query: $viewModel.uiState.query,
            onCreateConversationClick: onCreateConversationClick,
            onConversationClick: onConversationClick,
            onQueryChange: viewModel.onQueryChange,
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
    let conversations: [ConversationUi]?
    @Binding var query: String
    let onCreateConversationClick: () -> Void
    let onConversationClick: (ConversationUi) -> Void
    let onQueryChange: (String) -> Void
    let onDeleteConversationClick: (Conversation) -> Void
    
    @State private var selectedConversation: ConversationUi? = nil
    @State private var showBottomSheet: Bool = false
    @State private var isBottomSheetItemClicked: Bool = false
    @State private var showDeleteAlert: Bool = false
    
    var body: some View {
        ZStack {
            if let conversations = conversations {
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
                        VStack(spacing: 0) {
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
                        ClickableItemWithIcon(
                            icon: Image(systemName: "trash"),
                            text: Text(getString(.delete))
                        ) {
                            showBottomSheet = false
                            showDeleteAlert = true
                        }
                        .font(.title3)
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .presentationDetents([.fraction(0.10)])
                    }
                }
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
        }
        .searchable(
            text: $query,
            placement: .navigationBarDrawer(displayMode: .always)
        )
        .onChange(of: query) {
            onQueryChange($0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .navigationTitle(getString(.messages))
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(
                    action: onCreateConversationClick,
                    label: { Image(systemName: "plus") }
                )
            }
        }
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
            conversations: [],
            query: .constant(""),
            onCreateConversationClick: {},
            onConversationClick: {_ in},
            onQueryChange: {_ in},
            onDeleteConversationClick: {_ in}
        )
    }
}
