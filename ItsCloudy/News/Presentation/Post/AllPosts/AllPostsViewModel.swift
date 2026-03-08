import Combine
import Foundation

class AllPostsViewModel: ViewModel {
    private let userRepository: UserRepository
    private let postRepository: PostRepository
    private let deletePostUseCase: DeletePostUseCase
    private let recreatePostUseCase: RecreatePostUseCase
    private let refreshPostsUseCase: RefreshPostsUseCase
    
    @Published private(set) var uiState: AllPostsUiState = AllPostsUiState()
    @Published private(set) var event: SingleUiEvent? = nil
    private var cancellables: Set<AnyCancellable> = []

    init(
        userRepository: UserRepository,
        postRepository: PostRepository,
        deletePostUseCase: DeletePostUseCase,
        recreatePostUseCase: RecreatePostUseCase,
        refreshPostsUseCase: RefreshPostsUseCase
    ) {
        self.userRepository = userRepository
        self.postRepository = postRepository
        self.deletePostUseCase = deletePostUseCase
        self.recreatePostUseCase = recreatePostUseCase
        self.refreshPostsUseCase = refreshPostsUseCase
        
        listenPosts()
        listenUser()
    }
    
    func refreshPosts() async {
        try? await refreshPostsUseCase.execute()
    }

    
    func recreatePost(post: Post) {
        Task {
            await recreatePostUseCase.execute(post: post)
        }
    }
    
    func deletePost(post: Post) {
        performRequest { [weak self] in
            try await self?.deletePostUseCase.execute(post: post)
        }
    }
    
    private func performRequest(block: @escaping () async throws -> Void) {
        performUiBlockingRequest(
            block: block,
            onLoading: { [weak self] in
                self?.uiState.loading = true
            },
            onError: { [weak self] in
                self?.event = ErrorEvent(message: $0.localizedDescription)
            },
            onFinshed: { [weak self] in
                self?.uiState.loading = false
            }
        )
    }
    
    private func listenUser() {
        userRepository.user
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                self?.uiState.user = user
            }
            .store(in: &cancellables)
    }
    
    private func listenPosts() {
        postRepository.posts
            .receive(on: DispatchQueue.main)
            .sink { [weak self] posts in
                self?.uiState.posts = posts
            }
            .store(in: &cancellables)
    }
    
    struct AllPostsUiState {
        fileprivate(set) var posts: [Post]? = nil
        fileprivate(set) var user: User? = nil
        fileprivate(set) var loading: Bool = false
    }
}
