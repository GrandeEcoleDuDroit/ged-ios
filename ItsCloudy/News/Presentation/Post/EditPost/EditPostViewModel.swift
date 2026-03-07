import Combine
import Foundation

class EditPostViewModel: ViewModel {
    private let post: Post
    private let updatePostUseCase: UpdatePostUseCase
    
    @Published var uiState = EditPostUiState()
    @Published var event: SingleUiEvent?

    private let postUpdateState = CurrentValueSubject<PostUpdateState, Never>(PostUpdateState())
    private var cancellables: Set<AnyCancellable> = []
    
    init(
        post: Post,
        updatePostUseCase: UpdatePostUseCase
    ) {
        self.post = post
        self.updatePostUseCase = updatePostUseCase
        initUiState()
        listenPostUpdateState()
    }
    
    private func initUiState() {
        uiState = EditPostUiState(
            title: post.title,
            postLink: post.link,
            postSource: post.source,
            content: post.content ?? "",
            imageReferences: post.state.imageReferenceValues.map(ImageReference.imageUrl)
        )
    }
    
    func updatePost() {
        guard let source = uiState.postSource else { return }
        let (
            title,
            link,
            content,
            imageReferences
        ) = (
            uiState.title,
            uiState.postLink,
            uiState.content,
            uiState.imageReferences
        )
        
        let newPost = post.copy {
            $0.title = title
            $0.content = content.isBlank() ? nil : content.trim()
            $0.link = link.trim()
            $0.source = source
        }
        
        performRequest { [weak self] in
            try await self?.updatePostUseCase.execute(post: newPost, imageReferences: imageReferences)
            self?.event = SuccessEvent()
        }
    }
    
    func onTitleChange(_ title: String) {
        let truncatedTitle = title.take(PostPresentationUtils.maxTitleLength)
        uiState.title = truncatedTitle
        postUpdateState.send(
            postUpdateState.value.copy {
                $0.titleUpdated = validateTitleUpdate(truncatedTitle)
                $0.validTitle = validateTitle(truncatedTitle)
            }
        )
    }
    
    func onPostLinkChange(_ postLink: String) {
        postUpdateState.send(
            postUpdateState.value.copy {
                $0.postLinkUpdated = validatePostLinkUpdate(postLink)
                $0.validPostLink = validatePostLink(postLink)
            }
        )
    }
    
    func onSelectPostSource(_ postSource: Post.PostSource) {
        let newPostSource = postSource == uiState.postSource ? nil : postSource
        uiState.postSource = newPostSource
        postUpdateState.send(
            postUpdateState.value.copy {
                $0.postSourceUpdated = validatePostSourceUpdate(newPostSource)
                $0.validPostSource = validatePostSource(newPostSource)
            }
        )
    }
    
    func onContentChange(_ content: String) {
        let truncatedContent = content.take(PostPresentationUtils.maxContentLength)
        uiState.content = truncatedContent
        postUpdateState.send(
            postUpdateState.value.copy {
                $0.contentUpdated = validateContentUpdate(truncatedContent)
                $0.validContent = validateContent(truncatedContent)
            }
        )
    }
    
    func onAddImageData(_ imageData: [Data]) {
        var newImageReferences = uiState.imageReferences
        var errorMessages: Set<String> = []
        
        for data in imageData {
            guard newImageReferences.count < PostPresentationUtils.maxImageCount else {
                errorMessages.insert(stringResource(.postMaxImageCountError, PostPresentationUtils.maxImageCount))
                break
            }
            
            guard data.count <= CommonPresentationUtils.maxImageFileSize else {
                errorMessages.insert(CommonPresentationUtils.imageTooLargeErrorMessage())
                continue
            }
            
            newImageReferences.append(ImageReference.imageData(data))
        }
        
        if !errorMessages.isEmpty {
            event = ErrorEvent(messages: errorMessages)
        }
        
        uiState.imageReferences = newImageReferences
        postUpdateState.send(
            postUpdateState.value.copy {
                $0.imageReferencesUpdated = validateImageReferencesUpdate(newImageReferences)
                $0.validImageReferences = validateImageReferences(newImageReferences)
            }
        )
    }
    
    func onRemoveImageReference(at index: Int) {
        var newImageReferences = uiState.imageReferences
        newImageReferences.remove(at: index)
        uiState.imageReferences = newImageReferences
        postUpdateState.send(
            postUpdateState.value.copy {
                $0.imageReferencesUpdated = validateImageReferencesUpdate(newImageReferences)
                $0.validImageReferences = validateImageReferences(newImageReferences)
            }
        )
    }
    
    private func validateTitleUpdate(_ title: String) -> Bool {
        title != post.title
    }
    
    private func validateTitle(_ title: String) -> Bool {
        title.isNotBlank()
    }
    
    private func validatePostLinkUpdate(_ postLink: String) -> Bool {
        postLink != post.link
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
    
    private func validatePostSourceUpdate(_ postSource: Post.PostSource?) -> Bool {
        postSource != post.source
    }
    
    private func validatePostSource(_ postSource: Post.PostSource?) -> Bool {
        postSource != nil
    }
    
    private func validateContentUpdate(_ content: String) -> Bool {
        content != post.content
    }
    
    private func validateContent(_ content: String) -> Bool {
        content.isNotBlank()
    }
    
    private func validateImageReferencesUpdate(_ imageReferences: [ImageReference]) -> Bool {
        imageReferences.map(\.value) != post.state.imageReferenceValues
    }
    
    private func validateImageReferences(_ imageReferences: [ImageReference]) -> Bool {
        !imageReferences.isEmpty && imageReferences.count <= PostPresentationUtils.maxImageCount
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

    private func listenPostUpdateState() {
        postUpdateState
            .sink { [weak self] state in
                self?.uiState.updateEnabled = state.valid
            }
            .store(in: &cancellables)
    }
    
    struct EditPostUiState {
        var title: String = ""
        var postLink: String = ""
        var postSource: Post.PostSource? = nil
        var content: String = ""
        var imageReferences: [ImageReference] = []
        var postLinkError: String? = nil
        var loading: Bool = false
        var updateEnabled: Bool = false
        
        let allPostSources: [Post.PostSource] = Post.PostSource.all
    }
    
    struct PostUpdateState: Copying {
        var titleUpdated: Bool = false
        var postLinkUpdated: Bool = false
        var postSourceUpdated: Bool = false
        var contentUpdated: Bool = false
        var imageReferencesUpdated: Bool = false
        
        var validTitle: Bool = true
        var validPostLink: Bool = true
        var validPostSource: Bool = true
        var validContent: Bool = true
        var validImageReferences: Bool = true
        
        var updated: Bool {
            titleUpdated ||
            postLinkUpdated ||
            postSourceUpdated ||
            contentUpdated ||
            imageReferencesUpdated
        }
        
        var valid: Bool {
            validTitle &&
            validPostLink &&
            validPostSource &&
            (validContent || validImageReferences)
        }
    }
}
