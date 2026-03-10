import Foundation
import Combine

class ReadPostViewModel: ViewModel {
    private let postId: String
    private let userRepository: UserRepository
    private let postRepository: PostRepository
    private let deletePostUseCase: DeletePostUseCase
    
    @Published private(set) var uiState = ReadPostUiState()
    @Published private(set) var event: SingleUiEvent? = nil
    private var cancellables: Set<AnyCancellable> = []
    
    init(
        postId: String,
        userRepository: UserRepository,
        postRepository: PostRepository,
        deletePostUseCase: DeletePostUseCase,
    ) {
        self.postId = postId
        self.userRepository = userRepository
        self.postRepository = postRepository
        self.deletePostUseCase = deletePostUseCase
        
        listenPost()
        listenUser()
    }
    
    func deletePost() {
        guard let post = uiState.post else { return }
        performRequest { [weak self] in
            try await self?.deletePostUseCase.execute(post: post)
            self?.event = ReadPostUiEvent.postDeleted
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
    
    private func listenPost() {
        postRepository.getPostPublisher(postId: postId)
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] post in
                self?.uiState.post = post
            }.store(in: &cancellables)
    }
    
    private func listenUser() {
        userRepository.user
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                self?.uiState.user = user
            }.store(in: &cancellables)
    }
    
    struct ReadPostUiState: Withable {
        var post: Post? = nil
        var user: User? = nil
        var loading: Bool = false
    }
    
    enum ReadPostUiEvent: SingleUiEvent {
        case postDeleted
    }
}
