import SwiftUI

struct AllPostsDestination: View {
    let onPostClick: (String) -> Void
    
    @StateObject private var viewModel = NewsMainThreadInjector.shared.resolve(AllPostsViewModel.self)
    @State private var errorAlert = AlertData("")
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        if let user = viewModel.uiState.user, let posts = viewModel.uiState.posts {
            AllPostsView(
                user: user,
                posts: posts,
                loading: viewModel.uiState.loading,
                onRefresh: viewModel.refreshPosts,
                onPostClick: onPostClick,
                onRedirectPostClick: { postLink in
                    if let url = URL(string: postLink) {
                        openURL(url)
                    }
                },
                onRecreatePostClick: { viewModel.recreatePost(post: $0) },
                onDeletePostClick: { viewModel.deletePost(post: $0) }
            )
            .onReceive(viewModel.$event) { event in
                if let errorEvent = event as? ErrorEvent {
                    errorAlert = AlertData(errorEvent.message)
                    errorAlert.present()
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
        } else {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
    }
}

private struct AllPostsView: View {
    let user: User
    let posts: [Post]
    let loading: Bool
    let onRefresh: () async -> Void
    let onPostClick: (String) -> Void
    let onRedirectPostClick: (String) -> Void
    let onRecreatePostClick: (Post) -> Void
    let onDeletePostClick: (Post) -> Void
    
    @State private var activeSheet: AllPostViewSheet?
    @State private var deletePostAlert = AlertData<Post>(stringResource(.deletePostAlertMessage))

    var body: some View {
        List {
            if posts.isEmpty {
                EmptyText(stringResource(.noPost))
            } else {
                ForEach(posts) { post in
                    ExtendedPostItem(
                        post: post,
                        onRedirectPostClick: { onRedirectPostClick(post.link) },
                        onOptionClick: {
                            activeSheet = .post(post)
                        }
                    )
                    .onTapGesture {
                        if post.state.type == .publishedType {
                            onPostClick(post.id)
                        } else {
                            activeSheet = .post(post)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
            }
        }
        .listStyle(.plain)
        .refreshable { await onRefresh() }
        .loading(loading)
        .navigationTitle(stringResource(.allPosts))
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $activeSheet) {
            switch $0 {
                case let .post(post):
                    PostSheet(
                        postState: post.state,
                        editable: user.admin,
                        onEditClick: {
                            activeSheet = .editPost(post)
                        },
                        onRecreateClick: {
                            activeSheet = nil
                            onRecreatePostClick(post)
                        },
                        onDeleteClick: {
                            activeSheet = nil
                            deletePostAlert.present(data: post)
                        },
                        onReportClick: {
                            // TODO
                        }
                    )
                    
                case let .editPost(post):
                    EditPostDestination(
                        post: post,
                        onCancelClick: { activeSheet = nil }
                    )
            }
        }
        .alert(
            deletePostAlert.title,
            isPresented: $deletePostAlert.presented,
            presenting: deletePostAlert.data,
            actions: { post in
                Button(stringResource(.cancel), role: .cancel) {
                    deletePostAlert.dismiss()
                }
                
                Button(stringResource(.delete), role: .destructive) {
                    onDeletePostClick(post)
                    deletePostAlert.dismiss()
                }
            }
        )
    }
}

private enum AllPostViewSheet: Identifiable {
    case post(Post)
    case editPost(Post)
    
    var id: Int {
        switch self {
            case .post: 0
            case .editPost: 1
        }
    }
}

#Preview {
    NavigationStack {
        AllPostsView(
            user: userFixture,
            posts: postsFixture,
            loading: false,
            onRefresh: {},
            onPostClick: { _ in },
            onRedirectPostClick: { _ in },
            onRecreatePostClick: { _ in },
            onDeletePostClick: {  _ in }
        )
    }
    .environment(\.managedObjectContext, GedDatabaseContainer.preview.container.viewContext)
}
