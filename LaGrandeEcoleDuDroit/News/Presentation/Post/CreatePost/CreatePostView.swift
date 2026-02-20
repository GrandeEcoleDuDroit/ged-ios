import SwiftUI

struct CreatePostDestination: View {
    let onCancelClick: () -> Void
    @StateObject private var viewModel = NewsMainThreadInjector.shared.resolve(CreatePostViewModel.self)
    @State private var errorMessage: String = ""
    @State private var showErrorAlert: Bool = false

    var body: some View {
        CreatePostView(
            title: $viewModel.uiState.title,
            postLink: $viewModel.uiState.postLink,
            postSource: viewModel.uiState.postSource,
            allPostSources: viewModel.uiState.allPostSources,
            content: $viewModel.uiState.content,
            imageData: viewModel.uiState.imageData,
            postLinkError: viewModel.uiState.postLinkError,
            createEnabled: viewModel.uiState.createEnabled,
            onTitleChange: viewModel.onTitleChange,
            onPostLinkChange: viewModel.onPostLinkChange,
            onPostSourceChange: viewModel.onSelectPostSource,
            onContentChange: viewModel.onContentChange,
            onAddImageData: viewModel.onAddImageData,
            onRemoveImageData: viewModel.onRemoveImageData,
            onCancelClick: onCancelClick,
            onCreatePostClick: {
                viewModel.createPost()
                onCancelClick()
            }
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

private struct CreatePostView: View {
    @Binding var title: String
    @Binding var postLink: String
    let postSource: Post.PostSource?
    let allPostSources: [Post.PostSource]
    @Binding var content: String
    let imageData: [Data]
    let postLinkError: String?
    let createEnabled: Bool
    let onTitleChange: (String) -> Void
    let onPostLinkChange: (String) -> Void
    let onPostSourceChange: (Post.PostSource) -> Void
    let onContentChange: (String) -> Void
    let onAddImageData: ([Data]) -> Void
    let onRemoveImageData: (Int) -> Void
    let onCancelClick: () -> Void
    let onCreatePostClick: () -> Void
    
    var body: some View {
        
    }
}

#Preview {
    CreatePostView(
        title: .constant(""),
        postLink: .constant(""),
        postSource: nil,
        allPostSources: Post.PostSource.all,
        content: .constant(""),
        imageData: [],
        postLinkError: nil,
        createEnabled: false,
        onTitleChange: { _ in },
        onPostLinkChange: { _ in },
        onPostSourceChange: { _ in },
        onContentChange: { _ in },
        onAddImageData: { _ in },
        onRemoveImageData: { _ in },
        onCancelClick: {},
        onCreatePostClick: {}
    )
}
