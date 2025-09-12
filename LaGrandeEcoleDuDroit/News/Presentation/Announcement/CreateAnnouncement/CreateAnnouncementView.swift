import SwiftUI

struct CreateAnnouncementDestination: View {
    let onBackClick: () -> Void
    
    @StateObject private var viewModel: CreateAnnouncementViewModel = NewsInjection.shared.resolve(CreateAnnouncementViewModel.self)
    @State private var errorMessage: String = ""
    @State private var showErrorAlert: Bool = false
    
    var body: some View {
        CreateAnnouncementView(
            title: $viewModel.uiState.title,
            content: $viewModel.uiState.content,
            loading: viewModel.uiState.loading,
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
    @Binding var title: String
    @Binding var content: String
    let loading: Bool
    let enableCreate: Bool
    let onTitleChange: (String) -> Void
    let onContentChange: (String) -> Void
    let onCreateClick: () -> Void
    @State private var focusedInputField: InputField? = nil
    
    var body: some View {
        AnnouncementInput(
            title: $title,
            content: $content,
            focusedInputField: $focusedInputField,
            onTitleChange: onTitleChange,
            onContentChange: onContentChange
        )
        .navigationTitle(getString(.newAnnouncement))
        .navigationBarTitleDisplayMode(.inline)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding()
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(
                    action: onCreateClick,
                    label: {
                        if !enableCreate {
                            Text(getString(.post))
                                .fontWeight(.semibold)
                        } else {
                            Text(getString(.post))
                                .foregroundColor(.gedPrimary)
                                .fontWeight(.semibold)
                        }
                    }
                )
                .disabled(!enableCreate || loading)
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
    }
}

#Preview {
    NavigationStack {
        CreateAnnouncementView(
            title: .constant(""),
            content: .constant(""),
            loading: false,
            enableCreate: false,
            onTitleChange: { _ in },
            onContentChange: { _ in },
            onCreateClick: {}
        )
    }
}
