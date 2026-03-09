import SwiftUI

struct EditPostDestination: View {
    let onCancelClick: () -> Void
    
    @StateObject private var viewModel: EditPostViewModel
    @State private var errorAlert = AlertData("")
    
    init(
        post: Post,
        onCancelClick: @escaping () -> Void
    ) {
        self.onCancelClick = onCancelClick
        self._viewModel = StateObject(
            wrappedValue: NewsMainThreadInjector.shared.resolve(EditPostViewModel.self, arguments: post)!
        )
    }

    var body: some View {
        NavigationStack {
            EditPostView(
                title: $viewModel.uiState.title,
                postLink: $viewModel.uiState.postLink,
                postSource: viewModel.uiState.postSource,
                allPostSources: viewModel.uiState.allPostSources,
                content: $viewModel.uiState.content,
                imageReferences: viewModel.uiState.imageReferences,
                postLinkError: viewModel.uiState.postLinkError,
                loading: viewModel.uiState.loading,
                updateEnabled: viewModel.uiState.updateEnabled,
                onTitleChange: viewModel.onTitleChange,
                onPostLinkChange: viewModel.onPostLinkChange,
                onPostSourceChange: viewModel.onSelectPostSource,
                onContentChange: viewModel.onContentChange,
                onAddImageData: viewModel.onAddImageData,
                onRemoveImageReference: viewModel.onRemoveImageReference,
                onCancelClick: onCancelClick,
                onUpdatePostClick: viewModel.updatePost
            )
            .onReceive(viewModel.$event) { event in
                if let errorEvent = event as? ErrorEvent {
                    errorAlert = AlertData(errorEvent.message)
                    errorAlert.present()
                } else if event is SuccessEvent {
                    onCancelClick()
                }
            }
            .alert(
                errorAlert.title,
                isPresented: $errorAlert.presented,
                actions: {
                    Button(stringResource(.ok)) {
                        errorAlert.dismiss()
                    }
                }
            )
        }
    }
}

private struct EditPostView: View {
    @Binding var title: String
    @Binding var postLink: String
    let postSource: Post.PostSource?
    let allPostSources: [Post.PostSource]
    @Binding var content: String
    let imageReferences: [ImageReference]
    let postLinkError: String?
    let loading: Bool
    let updateEnabled: Bool
    let onTitleChange: (String) -> Void
    let onPostLinkChange: (String) -> Void
    let onPostSourceChange: (Post.PostSource) -> Void
    let onContentChange: (String) -> Void
    let onAddImageData: ([Data]) -> Void
    let onRemoveImageReference: (Int) -> Void
    let onCancelClick: () -> Void
    let onUpdatePostClick: () -> Void
    
    var body: some View {
        PostForm(
            value: PostFormValue(
                title: $title,
                postLink: $postLink,
                postSource: postSource,
                allPostSources: allPostSources,
                content: $content,
                imageReferences: imageReferences,
                postLinkError: postLinkError
            ),
            onTitleChange: onTitleChange,
            onPostLinkChange: onPostLinkChange,
            onPostSourceChange: onPostSourceChange,
            onContentChange: onContentChange,
            onAddImageData: onAddImageData,
            onRemoveImageClick: onRemoveImageReference
        )
        .padding(.horizontal)
        .loading(loading)
        .navigationTitle(stringResource(.editPost))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(
                    stringResource(.cancel),
                    action: onCancelClick
                )
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Button(action: onUpdatePostClick) {
                    if updateEnabled && !loading {
                        Text(stringResource(.save))
                            .foregroundStyle(.appPrimary)
                    } else {
                        Text(stringResource(.save))
                    }
                }
                .disabled(!updateEnabled || loading)
            }
        }
    }
}

#Preview {
    NavigationStack {
        EditPostView(
            title: .constant(""),
            postLink: .constant(""),
            postSource: nil,
            allPostSources: Post.PostSource.all,
            content: .constant(""),
            imageReferences: [],
            postLinkError: nil,
            loading: false,
            updateEnabled: false,
            onTitleChange: { _ in },
            onPostLinkChange: { _ in },
            onPostSourceChange: { _ in },
            onContentChange: { _ in },
            onAddImageData: { _ in },
            onRemoveImageReference: { _ in },
            onCancelClick: {},
            onUpdatePostClick: {}
        )
    }
}

