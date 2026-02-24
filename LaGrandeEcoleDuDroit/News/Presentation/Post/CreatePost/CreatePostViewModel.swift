import Combine
import Foundation

class CreatePostViewModel: ViewModel {
    private let createPostUseCase: CreatePostUseCase
    private let generateIdUseCase: GenerateIdUseCase
    
    @Published var uiState = CreatePostUiState()
    @Published var event: SingleUiEvent?

    private let postCreateState = CurrentValueSubject<CreatePostViewModel.PostCreateState, Never>(PostCreateState())
    private var cancellables: Set<AnyCancellable> = []
    
    init(
        createPostUseCase: CreatePostUseCase,
        generateIdUseCase: GenerateIdUseCase
    ) {
        self.createPostUseCase = createPostUseCase
        self.generateIdUseCase = generateIdUseCase
        listenPostCreateState()
    }
    
    func onTitleChange(_ title: String) {
        let truncatedTitle = title.take(PostPresentationUtils.maxTitleLength)
        uiState.title = truncatedTitle
        postCreateState.send(
            postCreateState.value.copy { $0.validTitle = validateTitle(truncatedTitle) }
        )
    }
    
    func onPostLinkChange(_ postLink: String) {
        postCreateState.send(
            postCreateState.value.copy { $0.validPostLink = validatePostLink(postLink) }
        )
    }
    
    func onSelectPostSource(_ postSource: Post.PostSource) {
        let newPostSource = postSource == uiState.postSource ? nil : postSource
        uiState.postSource = newPostSource
        postCreateState.send(
            postCreateState.value.copy { $0.validPostSource = validatePostSource(newPostSource) }
        )
    }
    
    func onContentChange(_ content: String) {
        let truncatedContent = content.take(PostPresentationUtils.maxContentLength)
        uiState.content = truncatedContent
        postCreateState.send(
            postCreateState.value.copy { $0.validContent = validateContent(truncatedContent) }
        )
    }
    
    func onAddImageData(_ imageData: [Data]) {
        var newImageData = uiState.imageData
        var errorMessages: Set<String> = []
        
        for data in imageData {
            guard newImageData.count < PostPresentationUtils.maxImageCount else {
                errorMessages.insert(stringResource(.postMaxImageCountError, PostPresentationUtils.maxImageCount))
                break
            }
            
            guard data.count <= CommonPresentationUtils.maxImageFileSize else {
                errorMessages.insert(CommonPresentationUtils.imageTooLargeErrorMessage())
                continue
            }
            
            newImageData.append(data)
        }
        
        if !errorMessages.isEmpty {
            event = ErrorEvent(messages: errorMessages)
        }
        
        uiState.imageData = newImageData
        postCreateState.send(
            postCreateState.value.copy { $0.validImageData = validateImageData(newImageData) }
        )
    }
    
    func onRemoveImageData(at index: Int) {
        var newImageData = uiState.imageData
        newImageData.remove(at: index)
        uiState.imageData = newImageData
        postCreateState.send(
            postCreateState.value.copy { $0.validImageData = validateImageData(newImageData) }
        )
    }
    
    func createPost() {
        guard postCreateState.value.valid else { return }
        guard let source = uiState.postSource else { return }
        let (
            title,
            link,
            content,
            imageData
        ) = (
            uiState.title,
            uiState.postLink,
            uiState.content,
            uiState.imageData
        )
        
        let post = Post(
            id: generateIdUseCase.execute(),
            title: title,
            content: content,
            link: link,
            source: source,
            date: Date(),
            state: .draft
        )
        
        Task {
            await createPostUseCase.execute(post: post, imageData: imageData)
        }
        event = SuccessEvent()
    }
    
    private func validateTitle(_ title: String) -> Bool {
        title.isNotBlank()
    }
    
    private func validatePostLink(_ postLink: String) -> Bool {
        let postLinkError: String? = switch postLink {
            case _ where postLink.count > PostPresentationUtils.maxPostLinkLength:
                stringResource(.postLinkLengthError, PostPresentationUtils.maxPostLinkLength)
                
            default: nil
        }
        uiState.postLinkError = postLinkError
        return postLinkError == nil && postLink.isNotBlank()
    }
    
    private func validatePostSource(_ postSource: Post.PostSource?) -> Bool {
        postSource != nil
    }
    
    private func validateContent(_ content: String) -> Bool {
        content.isNotBlank()
    }
    
    private func validateImageData(_ imageData: [Data]) -> Bool {
        !imageData.isEmpty && imageData.count <= PostPresentationUtils.maxImageCount
    }

    private func listenPostCreateState() {
        postCreateState
            .sink { [weak self] state in
                self?.uiState.createEnabled = state.valid
            }
            .store(in: &cancellables)
    }
    
    struct CreatePostUiState {
        var title: String = ""
        var postLink: String = ""
        var postSource: Post.PostSource? = nil
        var content: String = ""
        var imageData: [Data] = []
        let allPostSources: [Post.PostSource] = Post.PostSource.all
        var createEnabled: Bool = false
        
        var postLinkError: String? = nil
    }
    
    struct PostCreateState: Copying {
        var validTitle: Bool = false
        var validPostLink: Bool = false
        var validPostSource: Bool = false
        var validContent: Bool = false
        var validImageData: Bool = true
        
        var valid: Bool {
            validTitle &&
            validPostLink &&
            validPostSource &&
            (validContent || validImageData)
        }
    }
}
