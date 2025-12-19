import SwiftUI

struct EditAnnouncementDestination: View {
    let onCancelClick: () -> Void
    
    @StateObject private var viewModel: EditAnnouncementViewModel
    @State private var errorMessage: String = ""
    @State private var showErrorAlert: Bool = false
    
    init(
        announcement: Announcement,
        onCancelClick: @escaping () -> Void
    ) {
        _viewModel = StateObject(
            wrappedValue: NewsMainThreadInjector.shared.resolve(EditAnnouncementViewModel.self, arguments: announcement)!
        )
        self.onCancelClick = onCancelClick
    }
    
    var body: some View {
        NavigationStack {
            EditAnnouncementView(
                title: $viewModel.uiState.title,
                content: $viewModel.uiState.content,
                loading: viewModel.uiState.loading,
                updateEnabled: viewModel.uiState.updateEnabled,
                onTitleChange: viewModel.onTitleChange,
                onContentChange: viewModel.onContentChange,
                onUpdateAnnouncementClick: viewModel.updateAnnouncement,
                onCancelClick: onCancelClick
            )
            .onReceive(viewModel.$event) { event in
                if let errorEvent = event as? ErrorEvent {
                    errorMessage = errorEvent.message
                    showErrorAlert = true
                } else if let _ = event as? SuccessEvent {
                    onCancelClick()
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
}

private struct EditAnnouncementView: View {
    @Binding var title: String
    @Binding var content: String
    let loading: Bool
    let updateEnabled: Bool
    let onTitleChange: (String) -> Void
    let onContentChange: (String) -> Void
    let onUpdateAnnouncementClick: () -> Void
    let onCancelClick: () -> Void
    
    @FocusState private var focusState: AnnouncementFocusField?

    var body: some View {
        AnnouncementInputs(
            title: $title,
            content: $content,
            onTitleChange: onTitleChange,
            onContentChange: onContentChange,
            focusState: _focusState
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding()
        .loading(loading)
        .navigationTitle(stringResource(.editAnnouncement))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(stringResource(.cancel)) {
                    onCancelClick()
                }
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Button(action: onUpdateAnnouncementClick) {
                    if !updateEnabled || loading {
                        Text(stringResource(.save))
                    } else {
                        Text(stringResource(.save))
                            .foregroundStyle(.gedPrimary)
                    }
                }
                .disabled(!updateEnabled)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                focusState = .title
            }
        }
        .disabled(loading)
    }
}

#Preview {
    NavigationStack {
        EditAnnouncementView( 
            title: .constant(announcementFixture.title!),
            content: .constant(announcementFixture.content),
            loading: false,
            updateEnabled: false,
            onTitleChange: {_ in },
            onContentChange: {_ in },
            onUpdateAnnouncementClick: {},
            onCancelClick: {}
        )
        .background(.appBackground)
    }
    .environment(\.managedObjectContext, GedDatabaseContainer.preview.container.viewContext)
}
