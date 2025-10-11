import SwiftUI

struct EditAnnouncementDestination: View {
    let onBackClick: () -> Void
    
    @StateObject private var viewModel: EditAnnouncementViewModel
    @State private var errorMessage: String = ""
    @State private var showErrorAlert: Bool = false
    
    init(
        announcement: Announcement,
        onBackClick: @escaping () -> Void
    ) {
        _viewModel = StateObject(
            wrappedValue: NewsMainThreadInjector.shared.resolve(EditAnnouncementViewModel.self, arguments: announcement)!
        )
        self.onBackClick = onBackClick
    }
    
    var body: some View {
        EditAnnouncementView(
            title: viewModel.uiState.title,
            content: viewModel.uiState.content,
            loading: viewModel.uiState.loading,
            editButtonEnable: viewModel.uiState.enableUpdate,
            onTitleChange: viewModel.onTitleChange,
            onContentChange: viewModel.onContentChange,
            onUpdateAnnouncementClick: viewModel.updateAnnouncement,
            onBackClick: onBackClick
        )
        .onReceive(viewModel.$event) { event in
            if let errorEvent = event as? ErrorEvent {
                errorMessage = errorEvent.message
                showErrorAlert = true
            } else if let _ = event as? SuccessEvent {
                onBackClick()
            }
        }
        .alert(
            errorMessage,
            isPresented: $showErrorAlert,
            actions: {
                Button(getString(.ok)) {
                    showErrorAlert = false
                }
            }
        )
    }
}

private struct EditAnnouncementView: View {
    let title: String
    let content: String
    let loading: Bool
    let editButtonEnable: Bool
    let onTitleChange: (String) -> Void
    let onContentChange: (String) -> Void
    let onUpdateAnnouncementClick: () -> Void
    let onBackClick: () -> Void
    
    @State private var focusedInputField: InputField? = nil

    var body: some View {
        AnnouncementInput(
            title: title,
            content: content,
            focusedInputField: $focusedInputField,
            onTitleChange: onTitleChange,
            onContentChange: onContentChange
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding()
        .loading(loading)
        .navigationTitle(getString(.editAnnouncement))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(getString(.cancel)) {
                   onBackClick()
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button(
                    action: onUpdateAnnouncementClick,
                    label: {
                        if !editButtonEnable || loading {
                            Text(getString(.save))
                                .fontWeight(.semibold)
                        } else {
                            Text(getString(.save))
                                .foregroundStyle(.gedPrimary)
                                .fontWeight(.semibold)
                        }
                    }
                )
                .disabled(!editButtonEnable)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                focusedInputField = InputField.title
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            focusedInputField = nil
        }
        .disabled(loading)
        .onChange(of: loading) { isLoading in
            if isLoading {
                focusedInputField = nil
            }
        }
    }
}

#Preview {
    NavigationStack {
        EditAnnouncementView( 
            title: announcementFixture.title ?? "",
            content: announcementFixture.content,
            loading: false,
            editButtonEnable: true,
            onTitleChange: {_ in },
            onContentChange: {_ in },
            onUpdateAnnouncementClick: {},
            onBackClick: {}
        )
    }
}
