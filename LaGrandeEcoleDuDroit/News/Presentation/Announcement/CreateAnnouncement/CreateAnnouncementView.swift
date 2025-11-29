import SwiftUI

struct CreateAnnouncementDestination: View {
    let onBackClick: () -> Void
    
    @StateObject private var viewModel = NewsMainThreadInjector.shared.resolve(CreateAnnouncementViewModel.self)
    @State private var errorMessage: String = ""
    @State private var showErrorAlert: Bool = false
    
    var body: some View {
        CreateAnnouncementView(
            title: viewModel.uiState.title,
            content: viewModel.uiState.content,
            enableCreate: viewModel.uiState.enableCreate,
            onTitleChange: viewModel.onTitleChange,
            onContentChange: viewModel.onContentChange,
            onCreateClick: {
                viewModel.createAnnouncement()
                onBackClick()
            }
        )
        .onReceive(viewModel.$event) { event in
            if let errorEvent = event as? ErrorEvent {
                errorMessage = errorEvent.message
                showErrorAlert = true
            } else if let _ = event as? SuccessEvent {
                onBackClick()
            }
        }
    }
}

private struct CreateAnnouncementView: View {
    let title: String
    let content: String
    let enableCreate: Bool
    let onTitleChange: (String) -> Void
    let onContentChange: (String) -> Void
    let onCreateClick: () -> Void
    
    @FocusState private var focusState: Field?
    
    var body: some View {
        AnnouncementInput(
            title: title,
            content: content,
            onTitleChange: onTitleChange,
            onContentChange: onContentChange,
            focusState: $focusState
        )
        .onTapGesture { focusState = nil }
        .navigationTitle(stringResource(.newAnnouncement))
        .navigationBarTitleDisplayMode(.inline)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding()
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: onCreateClick) {
                    if !enableCreate {
                        Text(stringResource(.publish))
                            .fontWeight(.semibold)
                    } else {
                        Text(stringResource(.publish))
                            .foregroundColor(.gedPrimary)
                            .fontWeight(.semibold)
                    }
                }
                .disabled(!enableCreate)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                focusState = .title
            }
        }
        .contentShape(Rectangle())
    }
}

#Preview {
    NavigationStack {
        CreateAnnouncementView(
            title: "",
            content: "",
            enableCreate: false,
            onTitleChange: { _ in },
            onContentChange: { _ in },
            onCreateClick: {}
        )
    }
}
