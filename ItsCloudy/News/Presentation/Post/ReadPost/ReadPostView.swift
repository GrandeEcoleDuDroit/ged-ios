import SwiftUI

struct ReadPostDestination: View {
    let onBackClick: () -> Void
    
    @StateObject private var viewModel: ReadPostViewModel
    @State private var showErrorAlert: Bool = false
    @State private var errorMessage: String = ""
    @Environment(\.openURL) private var openURL

    init(
        postId: String,
        onBackClick: @escaping () -> Void
    ) {
        _viewModel = StateObject(
            wrappedValue: NewsMainThreadInjector.shared.resolve(
                ReadPostViewModel.self,
                arguments: postId
            )!
        )
        self.onBackClick = onBackClick
    }
    
    var body: some View {
        if let post = viewModel.uiState.post, let user = viewModel.uiState.user {
            ReadPostView(
                post: post,
                user: user,
                loading: viewModel.uiState.loading,
                onRedirectPostClick: { postLink in
                    if let url = URL(string: postLink) {
                        openURL(url)
                    }
                },
                onDeletePostClick: viewModel.deletePost
            )
            .onReceive(viewModel.$event) { event in
                if let errorEvent = event as? ErrorEvent {
                    errorMessage = errorEvent.message
                    showErrorAlert = true
                } else if let readPostUiEvent = event as? ReadPostViewModel.ReadPostUiEvent {
                    switch readPostUiEvent {
                        case .postDeleted: onBackClick()
                    }
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

private struct ReadPostView: View {
    let post: Post
    let user: User
    let loading: Bool
    let onRedirectPostClick: (String) -> Void
    let onDeletePostClick: () -> Void
    
    @State private var showDeletePostAlert: Bool = false
    @State private var activeSheet: ReadPostViewSheet?
    
    var body: some View {
        VStack(alignment: .leading, spacing: DimensResource.mediumPadding) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: DimensResource.mediumPadding) {
                    Text(post.title)
                        .font(.title2)
                        .padding(.horizontal)
                    
                    PostSourceItem(
                        postSource: post.source,
                        date: post.date,
                        elapsedTimeValueFormat: .long
                    )
                    .padding(.horizontal)
                    
                    if !post.state.imageReferenceValues.isEmpty {
                        PostImagePages(postState: post.state)
                            .frame(maxWidth: .infinity)
                            .frame(height: DimensResource.News.postImageHeight)
                    }
                    
                    if let content = post.content {
                        Text(content)
                            .padding(.horizontal)
                    }
                }
            }
            
            OutlinedButton(
                stringResource(.see),
                modifier: Modifier(maxWidth: .infinity),
                action: { onRedirectPostClick(post.link) }
            )
            .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .loading(loading)
        .navigationTitle(stringResource(.post))
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $activeSheet) {
            switch $0 {
                case .post:
                    PostSheet(
                        postState: post.state,
                        editable: user.admin,
                        onEditClick: {
                            activeSheet = .editPost
                        },
                        onDeleteClick: {
                            activeSheet = nil
                            showDeletePostAlert = true
                        },
                        onReportClick: {
                            // TODO
                        }
                    )
                    
                case .editPost:
                    EditPostDestination(
                        post: post,
                        onCancelClick: { activeSheet = nil }
                    )
            }
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                OptionsButton(action: { activeSheet = .post })
            }
        }
        .alert(
            stringResource(.deletePostAlertMessage),
            isPresented: $showDeletePostAlert,
            actions: {
                Button(
                    stringResource(.cancel),
                    role: .cancel,
                    action: { showDeletePostAlert = false }
                )
                
                Button(
                    stringResource(.delete), role: .destructive,
                    action: onDeletePostClick
                )
            }
        )
    }
}

private enum ReadPostViewSheet: Identifiable {
    case post
    case editPost
    
    var id: Int {
        switch self {
            case .post: 0
            case .editPost: 1
        }
    }
}

#Preview {
    NavigationStack {
        ReadPostView(
            post: postFixture,
            user: userFixture,
            loading: false,
            onRedirectPostClick: { _ in },
            onDeletePostClick: {}
        )
        .background(.appBackground)
    }
    .environment(\.managedObjectContext, GedDatabaseContainer.preview.container.viewContext)
}
